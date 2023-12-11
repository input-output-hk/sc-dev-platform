parameter: {
    // +usage=Specify the domain you want to expose
    domains: [...string]

    // +usage=Specify some HTTP matchers, filters and actions.
    rules: [...{
        // +usage=An HTTP request path matcher. If this field is not specified, a default prefix match on the "/" path is provided.
        path?: {
            type: *"ImplementationSpecific" | "Exact" | "Prefix"
            value:    *"/" | string
        }
        port: int
    }]

    // +usage=Specify the ingress class to use
    ingressClass?: *"public" | "internal"
}

output: {}

outputs: ingress: {
    apiVersion: "networking.k8s.io/v1"
    kind:       "Ingress"
    metadata: {
        annotations: {
            "external-dns.alpha.kubernetes.io/hostname":      parameter.domains[0]
            "nginx.ingress.kubernetes.io/force-ssl-redirect": "true"
        }
        name:      context.name
        namespace: context.namespace
    }
    spec: {
        ingressClassName: [
            if parameter.ingressClass != _|_ {"nginx-\( parameter.ingressClass )"},
            "nginx-public",
        ][0]
        rules: [{
            host: parameter.domains[0]
            http: paths: [
                for rule in parameter.rules {
                    path: [
                        if rule.path.value != _|_ {rule.path.value},
                        "/",
                    ][0]
                    pathType: [
                        if rule.path.type != _|_ {rule.path.type},
                        "ImplementationSpecific",
                    ][0]
                    backend: service: {
                        name: context.name
                        if rule.port != _|_ {
                            port: number: rule.port
                        }
                    }},
            ]
        },
        ]}
}