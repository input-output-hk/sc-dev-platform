# Cardano Wallet Connector trait

## Overview

The Cardano Wallet Connector trait acts as an intermediary tool allowing seamless communication between your application and the Cardano wallet.

The parameters for implementing this trait are:

| Parameter | Default Value | Required | Description   |
|-------------- | -------------- | -------------- | -------------- |
| network | `preview`  | `true`  | Defines the network choice for the Cardano Wallet. The available options are "preview", "preprod" and "mainnet".      |
| port    | `8090`     | `false` | Defines the port where the Cardano Wallet will be listening for requests. The default value is 8090.                  |

Because the `cardano-wallet` stores its state in a persistent volume, this trait sets [Recreate](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#recreate-deployment) as its deployment strategy.

## Usage

An instance of how you can utilize this trait within a Kubvela application follows:

```yaml
apiVersion: core.oam.dev/v1beta1
kind: Application
metadata:
  name: dapps-certification
  namespace: dapps-certification-staging
spec:
  components:
    - name: dapps-certification
      type: webservice
      properties:
        image: ghcr.io/input-output-hk/plutus-certification:PLT-7784-k8s-sched
        imagePullPolicy: Always
        ports:
          - expose: true
            port: 80
            protocol: TCP
      traits:
        - type: cardano-wallet-connector
          properties:
            network: preview
```

> Disclaimer: The current state of this trait doesn't blocks you from using it inlined with `cardano-node-connector` but since they have some similarity we recommend you to avoid it.
