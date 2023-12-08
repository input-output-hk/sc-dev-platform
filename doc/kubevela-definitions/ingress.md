# NGINX feature toggle

## Overview

This feature toggle allows developers to declare their applications with private addresses for Ingress using the provided cue definition. It leverages the `parameter` and `output` sections to specify domains, HTTP matchers, filters, actions, and the desired ingress class. This capability allows resources to be allocated to a public or private loadbalancer based on a toggle feature represented in VelaUX.

Defining HTTPS rules for mapping request from an ingress to an application.

Here is an example of a dry run with the following output once the specific manadatory parameters have been filled.

```yaml
## From the trait https-route
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    external-dns.alpha.kubernetes.io/hostname: marlowe-runtime-preview-web.scdev.aws.iohkdev.io
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
  labels:
    app.oam.dev/appRevision: ""
    app.oam.dev/component: marlowe-web-server-preview-qa
    app.oam.dev/name: marlowe-web-server-preview-qa
    app.oam.dev/namespace: default
    app.oam.dev/resourceType: TRAIT
    trait.oam.dev/resource: ingress
    trait.oam.dev/type: https-route
  name: marlowe-web-server-preview-qa
  namespace: default
spec:
  ingressClassName: nginx-public
  rules:
    - host: marlowe-runtime-preview-web.scdev.aws.iohkdev.io
      http:
        paths:
          - backend:
              service:
                name: marlowe-web-server-preview-qa
                port:
                  number: 3780
            path: /
            pathType: ImplementationSpecific
```

The mandatory parameters are:

- **ingressClass**: The ingress class used for loadbalancer, toggle selection field with two choices (`public/public`)
- **domain**: The desired domain.
- **rules**: The specific http matches such as pathType which is an Exact or Prefix, and the port.

VelaUX Guidance:

To toggle the feature in VelaUX, follow these steps:

Open VelaUX and navigate to the desired application.
Add a trait in one of the added components. This is a plus sign.
Select the type which is a https-route.
Here a number of parameters needed to be filled, which are mandatory stated above.
The toggle to select between public and private is at the bottom of this page.
Choose between public and private for the ingressClass toggle field.
Provide the desired domain and rules in the corresponding input fields.
Deploy the changes to have the desired effect.
