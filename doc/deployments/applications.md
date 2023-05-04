# Applications

## Summary
We are making use of the [Open Application Model][oam] to provide a simple way to describe deployments as [Application][app] manifests. We will provide custom traits and component types that make it easy to work with the Smart Contracts cluster.

## Setup
You can either setup applications through [web ui][scdev-vela] or as a yaml manifest file in a repository. 

You can login to the [web platform][scdev-vela] with an iohk gmail account then you will need to request for access to your team's project or for a new project to be made. In the main `Applications` page, you can click `New Application` and start entering details.

Either way the information regarding parameters for components and traits specific to this cluster will be useful. If an application is made through the [web ui][scdev-vela], the yaml data for it can be found in the `Revisions` page with the `Detail` action (in the far right column). This would be useful if you wanted to first create the application with the UI then commit the yaml to the repository where the code is developed and manage the deployment with git.



Here is a template for an application manifest:
```yaml
apiVersion: core.oam.dev/v1beta1
kind: Application
metadata:
  name: cardano
  namespace: default
spec:
  components:
  - name: cardano-node
    type: daemon
    properties:
      addRevisionLabel: false
      env:
      - name: NETWORK
        value: preprod
      # cmd:
      # - hello
      exposeType: ClusterIP
      image: inputoutput/cardano-node
        value: preprod
      # memory: 1024Mi
      # cpu: "1"
    traits:
    - type: scaler
      properties:
        replicas: 1
    # - type: https-route
    #   properties:
    #   domains:
    #   - marlowe-playground.scdev.aws.iohkdev.io
    #   rules:
    #   - path:
    #       type: PathPrefix
    #       value: /api
    #     port: 8080

  policies:
  - name: default
    properties:
      clusters:
      - local
      namespace: default
    type: topology
  workflow:
    mode: {}
    steps:
    - meta:
        alias: Deploy To default
      name: default
      properties:
        policies:
        - default
      type: deploy
```

## Compnonents
Each application has a main component and optionally other side components. A component is where the main deployment information goes. There are various component types to choose from, you will likely want to use either the `webservice` or `daemon` type. `Webservice` for any service that will need an exposed port, and `daemon` for other long running services.

*Note:* Component types for cardano-node based services may be added in the future.

You can then set properties for the component to describe how it should be run. Currently, a published image is required for each component. Other information like environment variables, resource usage, or what command to run (default is the image entrypoint) can be included too. [Secrets][secrets] can be passed to the image through environment variables, as described in the [secrets][secrets] section.

Information about [workflows][workflows] and [policies][policies] can be found in kubevela website. For most use cases, the default workflow and policy (the one set in by the [web platform][scdev-vela] or in the above template) is enough.

### Traits
To make any other deployment features available for a component, you can specify traits.
Some generally useful traits are:
 - `scaler`: Replicate a component any number of times and ensure the service for the component points to a healthy instance.
 - `storage`: Add persistent storage to a component.
 - `https-route`: Make component service publicly accessible. The `secret` parameter can be left empty, because that will be automatically removed. The domain argument must be a sub-domain of `scdev.aws.iohkdev.io`, as that is the domain the cluster is configured for. To use another domain (for production instances), a request will need to be made.

In the [web platform][scdev-vela] traits can only be added once an application is created. There will be a plus button in the components section for an application under each component.

[oam]: https://oam.dev/ 
[app]: https://kubevela.io/docs/getting-started/core-concept
[secrets]: ./secrets.md
[scdev-vela]: https://vela.scdev.aws.iohkdev.io
[vela-policies]: https://kubevela.io/docs/end-user/policies/references
[vela-workflows]: https://kubevela.io/docs/end-user/workflow/overview
