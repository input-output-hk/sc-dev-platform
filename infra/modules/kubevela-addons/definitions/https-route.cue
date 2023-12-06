parameter: {
	// +usage=Specify the domain you want to expose
	domain: string

	// +usage=Specify some HTTP matchers, filters and actions.
	rules: [...{
		// +usage=An HTTP request path matcher. If this field is not specified, a default prefix match on the "/" path is provided.
		path?: {
			pathType:  *"ImplementationSpecific" | "Exact" | "Prefix"
			value: *"/" | string
	    }
        port: int
    }]

	// +usage=Specify the class of ingress to use
	ingressClass?: *"nginx-public" | "nginx-internal"
}

output: {}

outputs: {
    _ingressName: context.name + "-ingress"
    ingress: {
        apiVersion: "networking.k8s.io/v1"
        kind:       "Ingress"
        metadata: {
            annotations: {
                "external-dns.alpha.kubernetes.io/hostname": parameter.domain
            }
            name: _ingressName
            namespace: context.namespace
        }
        spec: { 
            ingressClassName: [
              if parameter.ingressClass != _|_ { parameter.ingressClass },
              "nginx-public",
            ][0]
            rules: [{
                host: parameter.domain
			    http: paths: [
			    for rule in parameter.rules {
				    path: [
                        if rule.path != _|_ { rule.path },
                        "/",
                    ][0]
                    pathType: [
				        if rule.pathType != _|_ { rule.pathType},
                        "ImplementationSpecific",
                    ][0]
			    	backend: service: {
				    	name: context.name
					    if rule.port != _|_ {
                            port: number: rule.port
                        }
				    }},
		        ]
            }
        ]}
    }
}
