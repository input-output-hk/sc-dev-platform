parameter: {
    secretName: string
}

#PatchConfig: {
  nix: {
    volumes: [{
        name: "configmap-nix"
        configMap: {
            defaultMode: 420
            name: "cm-\( context.name )-nix"
        }
    }]
    mountPath: "/etc/nix"
    }
   ssh: {
    volumes: [{
        name: "configmap-ssh"
        configMap: {
            defaultMode: 420
            name: "cm-\( context.name )-ssh"
        }
    }]
    mountPath: "/etc/ssh"
    }
}

_volumes: [
    #PatchConfig.nix.volumes + #PatchConfig.ssh.volumes
]

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
            ssh_known_hosts: """
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
	volumes: _volumes
	// +patchKey=name
    containers: [{
		name: context.name
        env: [{
            name: "token"
            valueFrom: secretKeyRef: {
                key: "token"
                name: parameter.secretName
            }
        }]
        volumeMounts: [{
            name: #PatchConfig.nix.volumes.name
            mountPath: #PatchConfig.nix.mountPath
        },{
            name: #PatchConfig.ssh.volumes.name
            mountPath: #PatchConfig.ssh.mountPath
        }]  
    }]
}