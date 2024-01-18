# Cardano Wallet Connector trait

## Overview

The Cardano Wallet Connector trait acts as an intermediary tool allowing seamless communication between your application and the Cardano wallet.

The ***required*** parameter for implementing this trait is:
 - `network`: Defines the network choice for the Cardano Wallet. The available options are "preview", "preprod" and "mainnet".

The *Recreate* deployment strategy has been defined as the default strategy for this trait.

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


