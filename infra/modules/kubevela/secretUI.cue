// This file was added to the cluster imperatively with vela config-template apply -f secretUI.cue
import (
	"encoding/base64"
	"encoding/json"
	"strconv"
)

metadata: {
	name:        "generic-secret"
	alias:       "Generic Secret"
	scope:       "project"
	description: "Generic Secret for Applications"
	sensitive:   true
}

template: {
	parameter: {

		// +usage=fields to include in secret data
		fields: [...{
			name: string
			value: string
		}]

	}

	output: {
		apiVersion: "v1"
		kind:       "Secret"
		metadata: {
			name:      context.name
			namespace: context.namespace
		}
		type: "Opaque"
		data: {
			for field in parameter.fields {
				"\(field.name)": base64.Encode(null, field.value)
			}
		}
	}
}
