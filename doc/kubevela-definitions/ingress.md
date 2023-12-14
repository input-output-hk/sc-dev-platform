# NGINX feature toggle

## Overview

This feature toggle allows developers to declare their applications with private addresses for Ingress using the provided cue definition. It leverages the `parameter` and `output` sections to specify domains, HTTP matchers, filters, actions, and the desired ingress class. This capability allows resources to be allocated to a public or private loadbalancer based on a toggle feature represented in VelaUX.

Defining HTTPS rules for mapping request from an ingress to an application.

To create a new https-route we have to add public/internal property.
The application definition for each is as follows:

**For public**

```yaml
traits:
  - properties:
      domains:
        - marlowe-runtime-mainnet-web.demo.scdev.aws.iohkdev.io
      rules:
        - port: 3780
    type: https-route
type: webservice
```

**For internal**

```yaml
traits:
  - properties:
      instanceClassName: internal
      domains:
        - marlowe-runtime-mainnet-web.demo.scdev.aws.iohkdev.io
      rules:
        - port: 3780
    type: https-route
type: webservice
```

The mandatory parameters are:

- **ingressClassName**: The ingress class used for loadbalancer, toggle selection field with two choices (`public/internal`)
- **domain**: The desired domain.
- **rules**: The specific http matches such as pathType which is an Exact or Prefix, and the port.

**Accessing Connection Through VPN**

For enhanced security, access to the connection is restricted to VPN users only. Ensure you are connected to the VPN before attempting to access the specified domain.

Confluence document on how to connect to our AWS services securely is located [_here_](https://input-output.atlassian.net/wiki/spaces/SCT/pages/4019617812/User+Handbook+Connecting+to+AWS+Services+Securely+using+OpenVPN+Client).
