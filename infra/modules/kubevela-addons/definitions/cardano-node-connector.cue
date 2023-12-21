parameter: {
  network: *"preview" | "preprod" | "mainnet"
}

patch: spec: template: spec: {
  // +patchKey=name
  volumes: [{
    name: "ipc",
    emptyDir: {}
  },{
    name: "node-config",
    emptyDir: {}
  }]
  // +patchKey=name
  containers: [
    {
      name: context.name
      volumeMounts: [{
        name: "ipc",
        mountPath: "/ipc",
      }]
      // +patchStrategy=retainKeys
      env: [{
        name: "CARDANO_NODE_SOCKET_PATH"
        value: "/ipc/node.socket"
      },{
        name: "NODE_CONFIG"
        value: "/node-config/network/\( parameter.network )/cardano-node/config.json"
      }]
    },
    {
      name:  "socat"
      image: "alpine/socat"
      imagePullPolicy: "Always"
      args: [
        "UNIX-LISTEN:/ipc/node.socket,fork",
        "TCP-CONNECT:cardano-node-\( parameter.network ).vela-system:8090"
      ]
      volumeMounts: [{
        name: "ipc",
        mountPath: "/ipc",
      }]
    } 
  ]
  initContainers: [{
    name: "node-config-cloner"
    image: "alpine/git"
    imagePullPolicy: "Always"
    args: [
      "clone",
      "--single-branch",
      "--",
      "https://github.com/input-output-hk/cardano-configurations", 
      "/node-config"
    ]
    volumeMounts: [{
      name: "node-config",
      mountPath: "/node-config",
    }]
  }]
} 
