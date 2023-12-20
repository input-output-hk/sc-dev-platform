# Applications

## Summary
We are making use of the [Open Application Model][oam] to provide a simple way to describe deployments as [Application][app] manifests. We will provide custom traits and component types that make it easy to work with the Smart Contracts cluster.

## Initial Setup
You can either setup applications through [web ui][scdev-vela] or as a yaml manifest file in a repository. To ensure applications are declaratively setup it is recommended to have a yaml manifest commited to the application repository. You must use the Web UI to register your repository with the cluster and view the status of your deployments.

You can login to the [web platform][scdev-vela] with an iohk gmail account then you will need to request for access to your team's project or for a new project to be made. In the main `Applications` page, you can click `New Application` and start entering details following the [Application Parameters](#application-parameters) section.

Your team's project will have one or more environments/namespaces associated with it. For teams with production applications, a production environment can be made. All applications should be created in the staging or default namespace for your project and you can utilize policies and workflow steps to deploy your application to another namespace (details below).

## Application Parameters

### Compnonents
Each application has a main component and optionally other side components. A component is where the main deployment information goes. There are various component types to choose from, you will likely want to use either the `webservice` or `daemon` type. `Webservice` for any service that will need an externally exposed port, and `daemon` for other long running services.

*Note:* Component types for cardano-node based services may be added in the future.

You can then set properties for the component to describe how it should be run. Currently, a published image is required for each component (see the [containers][containers] guide on how to make one). Other information like environment variables, resource usage, or what command to run (default is the image entrypoint) can be included too. [Secrets][secrets] can be passed to the image through environment variables, as described in the [secrets][secrets] section.

Information about [workflows][workflows] and [policies][policies] can be found in kubevela website. For most use cases, the default workflow and policy (set by the [web platform][scdev-vela]) is enough.

### Traits
To make any other deployment features available for a component, you can specify traits.
Some generally useful traits are:
 - `scaler`: Replicate a component any number of times and ensure the service for the component points to a healthy instance.
 - `storage`: Add persistent storage to a component.
 - `https-route`: Make component service publicly accessible. The `secret` parameter can be left empty, because that will be automatically removed. The domain argument must be a sub-domain of `scdev.aws.iohkdev.io` or `marlowe.iohk.io`, as they are the domains the cluster is configured for.

### Workflow
Each application has a workflow configuration that determines how it should be deployed. A workflow has one or more steps that will either be run in parallel with the `DAG` mode or one at a time with the `StepByStep` mode. Workflow steps have a type that determine what they will do and likely the only workflow type you will need is the `deploy` type. You should attach a `topology` policy to a `deploy` workflow to make sure the application gets deployed in your team's namespace.

You can have multiple deploy steps, usually one for each namespace/environment.

### Policies
A policy determines how applications should be deployed. The most useful policy types are `topology` and `override`.
 - `topology` specifies which cluster and namespace a workflow deploy step should send resources to.
 - `override` allows changing components (and connected traits) configuration based on the environment being deployed to.

### Example

Here is an example application manifest:
```yaml
apiVersion: core.oam.dev/v1beta1
kind: Application
metadata:
  name: cardano
  namespace: cardano-staging # determined by the relevant project
spec:
  components:
  - name: cardano-node
    type: daemon # if it needs to be publicly available then "webservice" would be better
    properties:
      env:
      - name: NETWORK
        value: preprod
      # cmd: # If you wanted to run a command in the image other than the default entrypoint
      # - hello
      image: inputoutput/cardano-node
      # memory: 1024Mi # resources can be altered from the default by changing these settings
      # cpu: "1"
    traits:
    - type: scaler # the service can be replicated any number of times here
      properties:
        replicas: 1
    # - type: https-route # to make the service publicly available
    #   properties:
    #   domains:
    #   - cardano-node.scdev.aws.iohkdev.io
    #   rules:
    #   - path:
    #       type: PathPrefix
    #       value: /api
    #     port: 8080

  workflow:
    mode:
      steps: DAG # Use DAG execution mode (run steps in parallel)
    steps:
    - name: local-cardano-staging
      type: deploy
      meta:
        alias: Deploy To staging
      properties:
        policies:
        - local-cardano-staging
    # Following step is only needed for a separate production instance
    - name: local-cardano-production
      type: deploy
      meta:
        alias: Deploy To production
      properties:
        policies:
        - local-cardano-production
        - override-cardano-production

  policies:
  - name: local-cardano-staging
    type: topology
    properties:
      clusters:
      - local
      namespace: cardano-staging
  # Policies for production deploy workflow step
  - name: local-cardano-production
    type: topology
    properties:
      clusters:
      - local
      namespace: cardano-production
  - type: override
    name: override-cardano-production
    properties:
      components:
        - name: cardano-node # select what component will be overriden
          # type: daemon # to only select cardano-node components of this type (types cannot be overriden)
          properties: # properties to override
            env: # this list WILL NOT append to current env setting, so all original env entries should be included again
              - name: NETWORK
                value: mainnet
      traits: # only specified traits will be patched, so original traits don't need to be repeated
        - type: scaler # the service can be replicated any number of times here
          properties: # this WILL NOT be merged with existing trait configuration
            replicas: 1
   
      

  ```

[oam]: https://oam.dev/ 
[app]: https://kubevela.io/docs/getting-started/core-concept
[containers]: ./containers.md
[secrets]: ./secrets.md
[scdev-vela]: https://vela.scdev.aws.iohkdev.io
[vela-policies]: https://kubevela.io/docs/end-user/policies/references
[vela-workflows]: https://kubevela.io/docs/end-user/workflow/overview
