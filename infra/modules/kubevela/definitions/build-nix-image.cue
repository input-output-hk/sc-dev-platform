import (
	"vela/op"
	"encoding/json"
	"strings"
)

kaniko: op.#Apply & {
	value: {
		apiVersion: "v1"
		kind:       "Pod"
		metadata: {
			name:      "\(context.name)-\(context.stepSessionID)-kaniko"
			namespace: context.namespace
		}
		spec: {
			containers: [
				{
					args: [
						"--dockerfile=./infra/nix-docker-builder/Dockerfile",
						"--context=git://github.com/input-output-hk/sc-dev-platform#refs/heads/init-infra",
						"--destination=\(parameter.image)",
						"--verbosity=\(parameter.verbosity)",
						"--snapshot-mode=\(parameter.snapshotMode)",
						"--build-arg=INCLUDED_FLAKE_URIS=\(strings.Join(parameter.includedFlakeURIs, " "))",
						"--build-arg=ENTRYPOINT_BIN_NAME=\(parameter.entrypointBinName)",
						if parameter.platform != _|_ {
							"--customPlatform=\(parameter.platform)"
						},
						if parameter.buildArgs != _|_ for arg in parameter.buildArgs {
							"--build-arg=\(arg)"
						},
						if parameter.singleSnapshot {
							"--single-snapshot"
						},
					]
					image: parameter.kanikoExecutor
					if parameter.requests != _|_ && parameter.requests.ephemeralStorage != _|_ {
						resources: {
							requests: {
								"ephemeral-storage": parameter.requests.ephemeralStorage
							}
						}
					}
					name:  "kaniko"
					if parameter.credentials != _|_ && parameter.credentials.image != _|_ {
						volumeMounts: [
							{
								mountPath: "/kaniko/.docker/"
								name:      parameter.credentials.image.name
							},
						]
					}
					if parameter.credentials != _|_ && parameter.credentials.git != _|_ {
						env: [
							{
								name: "GIT_TOKEN"
								valueFrom: {
									secretKeyRef: {
										key:  parameter.credentials.git.key
										name: parameter.credentials.git.name
									}
								}
							},
						]
					}
				},
			]
			if parameter.credentials != _|_ && parameter.credentials.image != _|_ {
				volumes: [
					{
						name: parameter.credentials.image.name
						secret: {
							defaultMode: 420
							items: [
								{
									key:  parameter.credentials.image.key
									path: "config.json"
								},
							]
							secretName: parameter.credentials.image.name
						}
					},
				]
			}
			restartPolicy: "Never"
		}
	}
}
log: op.#Log & {
	source: {
		resources: [{
			name:      "\(context.name)-\(context.stepSessionID)-kaniko"
			namespace: context.namespace
		}]
	}
}
read: op.#Read & {
	value: {
		apiVersion: "v1"
		kind:       "Pod"
		metadata: {
			name:      "\(context.name)-\(context.stepSessionID)-kaniko"
			namespace: context.namespace
		}
	}
}
wait: op.#ConditionalWait & {
	continue: read.value.status != _|_ && read.value.status.phase == "Succeeded"
}
#secret: {
	name: string
	key:  string
}
#git: {
	git:    *"github.com/input-output-hk/sc-dev-platform" | string
	branch: *"init-infra" | string
}
parameter: {
	// +usage=Specify the kaniko executor image, default to oamdev/kaniko-executor:v1.9.1
	kanikoExecutor: *"oamdev/kaniko-executor:v1.9.1" | string
	// +usage=Specify the image
	image: string
	// +usage=Specify list of flake reference uris to include in image
	includedFlakeURIs: [...string]
	// +usage=Specify name of file in /bin in the profile to select as entrypoint
	entrypointBinName: *"bash" | string
	// +usage=Specify the platform to build
	platform?: string
	// +usage=Specify the build args
	buildArgs?: [...string]
	// +usage=Specify the credentials to access git and image registry
	credentials?: {
		// +usage=Specify the credentials to access git
		git?: {
			// +usage=Specify the secret name
			name: string
			// +usage=Specify the secret key
			key: string
		}
		// +usage=Specify the credentials to access image registry
		image?: {
			// +usage=Specify the secret name
			name: *"iohk-ghcr-creds" | string
			// +usage=Specify the secret key
			key: *".dockerconfigjson" | string
		}
	}
	// +usage=Specify resource requests for the kaniko build
	requests?: {
		// +usage=Request a specified storage size
		ephemeralStorage?: string
	}
	// +usage=Set the --single-snapshot flag https://github.com/GoogleContainerTools/kaniko#flag---single-snapshot
	singleSnapshot: *true | false
	// +usage=Set the --snapshot-mode flag https://github.com/GoogleContainerTools/kaniko#flag---single-snaphot-mode
	snapshotMode: *"redo" | "full" | "time"
	// +usage=Specify the verbosity level
	verbosity: *"info" | "panic" | "fatal" | "error" | "warn" | "debug" | "trace"
}
