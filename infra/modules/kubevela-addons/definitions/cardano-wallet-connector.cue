parameter: {
	network:       *"preview" | "preprod" | "mainnet"
}

#cardanoWalletConfigs: {
  volumes: [{
    name: "wallet-db"
    persistentVolumeClaim: {
      claimName: "wallet-db"
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

#PatchConfig: {
  volumes: [#cardanoNodeConfigs.volumes + #cardanoWalletConfigs.volumes][0]
  envs: [#cardanoNodeConfigs.envs][0]
}

patch: spec: {
  // +patchStrategy=retainKeys
  strategy: {
    type: "Recreate"
  }
  template: spec: {
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
        name:            "cardano-wallet-\( parameter.network )"
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
          path: "/\( #cardanoNodeConfigs.volumes[0].name )"
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
    ]
  }
}

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
  }
}
