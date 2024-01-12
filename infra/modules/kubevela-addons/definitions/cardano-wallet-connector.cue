parameter: {
	network:       *"preview" | "preprod" | "mainnet"
	configCloner?: *true | false
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
        #configClonerConfigs.volumes + #cardanoNodeConfigs.volumes
      }
      if parameter.configCloner != true {
        #cardanoNodeConfigs.volumes
      }
    },
    #configClonerConfigs.volumes + #cardanoNodeConfigs.volumes
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
        "--listen-address",
        "0.0.0.0",
        "--testnet",
        "/config/\( parameter.network )/genesis-byron.json"
      ]
      volumes: [{
        name:      #cardanoNodeConfigs.volumes[0].name
        path: "/\( #configClonerConfigs.volumes[0].name )"
      }]
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
}
