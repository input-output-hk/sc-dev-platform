patch: spec: template: spec: {
	// +patchKey=name
	containers: [{
		resources: {
			if parameter.cpu != _|_ if parameter.memory != _|_ if parameter."ephemeral-storage" != _|_ if parameter.requests == _|_ if parameter.limits == _|_ {
				// +patchStrategy=retainKeys
				requests: {
					cpu:    parameter.cpu
					memory: parameter.memory
					"ephemeral-storage": parameter."ephemeral-storage"
				}
				// +patchStrategy=retainKeys
				limits: {
					cpu:    parameter.cpu
					memory: parameter.memory
					"ephemeral-storage": parameter."ephemeral-storage"
				}
			}

			if parameter.requests != _|_ {
				// +patchStrategy=retainKeys
				requests: {
					cpu:    parameter.requests.cpu
					memory: parameter.requests.memory
					"ephemeral-storage": parameter.requests."ephemeral-storage"
				}
			}
			if parameter.limits != _|_ {
				// +patchStrategy=retainKeys
				limits: {
					cpu:    parameter.limits.cpu
					memory: parameter.limits.memory
					"ephemeral-storage": parameter.limits."ephemeral-storage"
				}
			}
		}
	}]
}

parameter: {
	// +usage=Specify the amount of cpu for requests and limits
	cpu?: *1 | number | string
	// +usage=Specify the amount of memory for requests and limits
	memory?: *"2048Mi" | =~"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$"
	// +usage=Specify the amount of ephemeral storage for requests and limits
	"ephemeral-storage"?: *"10Gi" | =~"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$"
	// +usage=Specify the resources in requests
	requests?: {
		// +usage=Specify the amount of cpu for requests
		cpu: *1 | number | string
		// +usage=Specify the amount of memory for requests
		memory: *"2048Mi" | =~"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$"
		// +usage=Specify the amount of ephemeral storage for requests
		"ephemeral-storage": *"10Gi" | =~"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$"
	}
	// +usage=Specify the resources in limits
	limits?: {
		// +usage=Specify the amount of cpu for limits
		cpu: *1 | number | string
		// +usage=Specify the amount of memory for limits
		memory: *"2048Mi" | =~"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$"
		// +usage=Specify the amount of ephemeral storage for limits
		"ephemeral-storage": *"10Gi" | =~"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$"
	}
}
