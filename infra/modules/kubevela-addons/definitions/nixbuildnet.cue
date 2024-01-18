parameter: {
    secretName: string
}

#PatchConfig: {
  volumes: [{
    name: "configmap-nix"
    configMap: {
        defaultMode: 420
        name: "cm-\( context.name )-nix"
    }
  },{
    name: "configmap-ssh"
    configMap: {
        defaultMode: 420
        name: "cm-\( context.name )-ssh"
    }
  }]
}

outputs: {
    configmapNix: {
        apiVersion: "v1"
        data: "nix.conf": """
                store = ssh-ng://eu.nixbuild.net
                experimental-features = nix-command flakes
                require-sigs = true
                substituters = https://cache.nixos.org/ https://cache.iog.io ssh://eu.nixbuild.net
                trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= nixbuild.net/smart.contracts@iohk.io-1:s2PhQXWwsZo1y5IxFcx2D/i2yfvgtEnRBOZavlA8Bog=

                """
        kind: "ConfigMap"
        metadata: {
            name: "cm-\( context.name )-nix"
            namespace: context.namespace
        }
    }
    configmapSsh: {
        apiVersion: "v1"
        data: {
            ssh_config: """
                    Host eu.nixbuild.net
                      PreferredAuthentications none
                      User authtoken
                      SendEnv token

                    Host *
                    AddressFamily any
                    GlobalKnownHostsFile /etc/ssh/ssh_known_hosts

                    """

            ssh_known_hosts: """"
                    eu.nixbuild.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM 

                    """
        }
        kind: "ConfigMap"
        metadata: {
            name: "cm-\( context.name )-ssh"
            namespace: context.namespace
        }
    }
}

patch: spec: template: spec: {
	// +patchKey=name
	volumes: #PatchConfig.volumes
	// +patchKey=name
    containers: [
		name: context.name
        volumeMounts: [{
            name: #PatchConfig.volumes[0].name
            mountPath: "/etc/nix"
        },{
            name: #PatchConfig.volumes[1].name
            mountPath: "/etc/ssh"
        }]
    ]
}