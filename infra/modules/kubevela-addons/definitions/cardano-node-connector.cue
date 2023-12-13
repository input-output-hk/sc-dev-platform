import "encoding/json"

parameter: {
  network: *"preview" | string
  version?: *"latest" | string
  volumeMounts: *[{
    name: "ipc",
    mountPath: "/ipc",
  }] | [...]
  volumes: *[{
    name: "ipc",
    emptyDir: {}
  }] | [...]
}

patch: spec: template: spec: {
  ...
  volumes: parameter.volumes
  containers: [
    {
      ...
      volumeMounts: parameter.volumeMounts
    },
    {
      name:  "socat"
      image: "alpine/socat"
      args: [
        "UNIX-LISTEN:/ipc/node.socket,fork",
        "TCP-CONNECT:cardano-node-\( parameter.network ).vela-system:8090"
      ]
      volumeMounts: parameter.volumeMounts
    } 
  ]
} 
