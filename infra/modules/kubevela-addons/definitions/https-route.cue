parameter: {
    // +usage=Specify the domain you want to expose
    domains: [...string]

    // +usage=Specify some HTTP matchers, filters and actions.
    rules: [...{
        // +usage=An HTTP request path matcher. If this field is not specified, a default prefix match on the "/" path is provided.
        path?: {
<<<<<<< HEAD
            type:  *"ImplementationSpecific" | "Exact" | "Prefix"
            value: *"/" | string
=======
<<<<<<< HEAD
            type: *"ImplementationSpecific" | "Exact" | "Prefix"
=======
            pathType: *"ImplementationSpecific" | "Exact" | "Prefix"
>>>>>>> 9ba4b35 (PLT-8878 (#65))
            value:    *"/" | string
>>>>>>> 1849607 (PLT-8878 (#65))
        }
        port: int
    }]

    // +usage=Specify the ingress class to use
    ingressClass?: *"public" | "internal"
}

output: {}

outputs: {
    ingress: {
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
            tls: [{
                hosts: [parameter.domains[0]]
                secretName: "\( context.name )-tls"
            }]
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
    certificate: {
        apiVersion: "cert-manager.io/v1"
        kind:       "Certificate"
        metadata: {
            name:      context.name
            namespace: context.namespace
        }
        spec: {
            dnsNames: [parameter.domains[0]]
            issuerRef: {
                group: "cert-manager.io"
                kind:  "ClusterIssuer"
                name:  "letsencrypt"
            }
            secretName: "\( context.name )-tls"
        }
    }
<<<<<<< HEAD
=======
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
<<<<<<< HEAD
                        if rule.path.value != _|_ {rule.path.value},
                        "/",
                    ][0]
                    pathType: [
                        if rule.path.type != _|_ {rule.path.type},
=======
                        if rule.path != _|_ {rule.path},
                        "/",
                    ][0]
                    pathType: [
                        if rule.pathType != _|_ {rule.pathType},
>>>>>>> 9ba4b35 (PLT-8878 (#65))
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
>>>>>>> 1849607 (PLT-8878 (#65))
}