parameter: {
	network:       *"preview" | "preprod" | "mainnet"
	configCloner?: *true | false
}

#cardanoWalletConfigs: {
  volumes: [{
    name: "wallet-db"
    persistentVolumeClaim: {
      claimName: "wallet-db"
    }
  }, {
    name: "db"
    persistentVolumeClaim: {
      claimName: "db"
    }
  }]
  volumeMounts: [{
    name:      "wallet-db"
    mountPath: "/wallet-db"
    storageClassName: "ebs-sc"
    resources: {
      requests: {
        storage: "100Ki"
      }
    }
  }, {
    name:      "db"
    mountPath: "/db"
    storageClassName: "ebs-sc"
    resources: {
      requests: {
        storage: "100Ki"
      }
    }
  }]
}

#cardanoNodeConfigs: {
  volumes: [{
    name: "ipc"
    emptyDir: {}
  }]
  envs: [{
    name: "CARDANO_NODE_SOCKET_PATH"
    value: "/ipc/node.socket"
  }]
}

#configClonerConfigs: {
  volumes: [{
    name: "node-config"
    emptyDir: {}
  }]
  envs: [{
    name: "NODE_CONFIG"
    value: "/node-config/network/\( parameter.network )/cardano-node/config.json"
  }]
}

#PatchConfig: {
  volumes: [
    if parameter.configCloner != _|_ {
      if parameter.configCloner {
        #configClonerConfigs.volumes + #cardanoNodeConfigs.volumes + #cardanoWalletConfigs.volumes
      }
      if parameter.configCloner != true {
        #cardanoNodeConfigs.volumes
      }
    },
    #configClonerConfigs.volumes + #cardanoNodeConfigs.volumes + #cardanoWalletConfigs.volumes
  ][0]
  envs: [
    if parameter.configCloner != _|_ {
      if parameter.configCloner {
        #configClonerConfigs.envs + #cardanoNodeConfigs.envs
      }
      if parameter.configCloner != true {
        #cardanoNodeConfigs.envs
      }
    },
    #configClonerConfigs.envs + #cardanoNodeConfigs.envs
  ][0]
}

patch: spec: template: spec: {
	// +patchKey=name
	volumes: #PatchConfig.volumes
  // +patchKey=name
  volumeMounts: #cardanoWalletConfigs.volumeMounts,
	// +patchKey=name
	containers: [
		{
			name: context.name
			volumeMounts: [{
				name:      #cardanoNodeConfigs.volumes[0].name
				mountPath: "/\( #cardanoNodeConfigs.volumes[0].name )"
			}]
	    // +patchKey=name
			env: #PatchConfig.envs
		},
		{
			name:            "socat"
			image:           "alpine/socat"
			imagePullPolicy: "Always"
			args: [
				"UNIX-LISTEN:\( #cardanoNodeConfigs.envs[0].value ),fork",
				"TCP-CONNECT:cardano-node-\( parameter.network ).vela-system:8090",
			]
			volumeMounts: [{
				name:      #cardanoNodeConfigs.volumes[0].name
				mountPath: "/\( #cardanoNodeConfigs.volumes[0].name )"
			}]
		},
		{
			name:            "socat"
			image:           "alpine/socat"
			imagePullPolicy: "Always"
			args: [
				"UNIX-LISTEN:\( #cardanoNodeConfigs.envs[0].value ),fork",
				"TCP-CONNECT:cardano-node-\( parameter.network ).vela-system:8090",
			]
			volumeMounts: [{
				name:      #cardanoNodeConfigs.volumes[0].name
				mountPath: "/\( #cardanoNodeConfigs.volumes[0].name )"
			}]
		},
    {
      name:            "cardano-wallet"
      image:           "inputoutput/cardano-wallet:dev-master"
      imagePullPolicy: "Always"
      args: [
        "serve",
        "--node-socket",
        "/ipc/node.socket",
        "--database",
        "/wallet-db",
        "--listen-address",
        "0.0.0.0",
        "--testnet",
        "/config/\( parameter.network )/genesis-byron.json"
      ]
      volumes: [{
        name:      #cardanoNodeConfigs.volumes[0].name
        path: "/\( #configClonerConfigs.volumes[0].name )"
      }, {
        name:      #cardanoWalletConfigs.volumes[0].name
        path: "/\( #cardanoWalletConfigs.volumes[0].name )"
      }]
      volumeMounts: [{
        name:      #cardanoNodeConfigs.volumes[0].name
        mountPath: "/\( #cardanoNodeConfigs.volumes[0].name )"
        emptyDir: {}
      }]
    },
    {
      name:            "create-wallet"
      image:           "curlimages/curl:latest"
      imagePullPolicy: "Always"
      args: [
        "-X",
        "POST",
        "-H",
        "Accept: application/json",
        "-H",
        "Content-Type: application/json",
        "-d",
        "{\"name\":\"test_cf_1\",\"mnemonic_sentence\": [\"stock\",\"horn\",\"under\",\"crime\",\"acid\",\"tell\",\"repair\",\"brain\",\"shallow\",\"dinosaur\",\"candy\",\"sight\",\"memory\",\"antenna\",\"baby\",\"truck\",\"force\",\"chuckle\",\"elephant\",\"unhappy\",\"sentence\",\"control\",\"hold\",\"camera\"],\"passphrase\":\"test123456\"}",
        "http://localhost:8090/v2/wallets"
      ]
    },
	]
	initContainers: [
    if parameter.configCloner != _|_ {
      if parameter.configCloner != true {[]}
    },
    [{
		  name:            "node-config-cloner"
		  image:           "alpine/git"
		  imagePullPolicy: "Always"
		  args: [
			  "clone",
			  "--single-branch",
			  "--",
			  "https://github.com/input-output-hk/cardano-configurations",
			  "/node-config",
		  ]
		  volumeMounts: [{
			  name:      #configClonerConfigs.volumes[0].name
			  mountPath: "/\( #configClonerConfigs.volumes[0].name )"
		  }]
	  }]
  ][0]

  outputs: {
    "pvc-\( #cardanoWalletConfigs.volumes[0].persistentVolumeClaim.claimName )": {
      apiVersion: "v1",
      kind: "PersistentVolumeClaim",
      metadata: {
        name: #cardanoWalletConfigs.volumes[0].persistentVolumeClaim.claimName,
        namespace: context.namespace
      },
      spec: {
        accessModes: [
          "ReadWriteOnce"
        ],
        resources: {
          requests: {
            storage: #cardanoWalletConfigs.volumeMounts[0].resources.requests.storage
          }
        },
        storageClassName: #cardanoWalletConfigs.volumeMounts[0].storageClassName,
        volumeMode: "Filesystem"
      }
    },
    "pvc-\( #cardanoWalletConfigs.volumes[1].persistentVolumeClaim.claimName )": {
      apiVersion: "v1",
      kind: "PersistentVolumeClaim",
      metadata: {
        name: #cardanoWalletConfigs.volumes[1].persistentVolumeClaim.claimName,
        namespace: context.namespace
      },
      spec: {
        accessModes: [
          "ReadWriteOnce"
        ],
        resources: {
          requests: {
            storage: #cardanoWalletConfigs.volumeMounts[1].resources.requests.storage
          }
        },
        storageClassName: #cardanoWalletConfigs.volumeMounts[1].storageClassName,
        volumeMode: "Filesystem"
      }
    }
  }
}
