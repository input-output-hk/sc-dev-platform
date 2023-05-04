# Applications

## Summary
We are making use of the [Open Application Model][oam] to provide a simple way to describe deployments as [Application][app] manifests. We will provide custom traits and component types that make it easy to work with the Smart Contracts cluster.

## Setup
Create an application yaml file following this general format:
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
      #  - hello
      exposeType: ClusterIP
      image: inputoutput/cardano-node
        value: preprod
      # memory: 1024Mi
      # cpu: "1"
    traits:
    - properties:
        replicas: 1
      type: scaler
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
status: {}
```

## Compnonents
Each application has a main component and optionally other side components. A component is where the main deployment information goes. There are various component types to choose from, you will likely want to use either the `webservice` or `daemon` type. `Webservice` for any service that will need an exposed port, and `daemon` for other long running services.

*Note:* Component types for cardano-node based services may be added in the future.

You can then set properties for the component to describe how it should be run. Currently, a published image is required for each component. Other information like environment variables, resource usage, or what command to run (default is the image entrypoint) can be included too

[oam]: https://oam.dev/ 
[app]: https://kubevela.io/docs/getting-started/core-concept
