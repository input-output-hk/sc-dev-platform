# Cardano Wallet Connector trait

## Overview

The Cardano Wallet Connector trait in KubeVela serves as a pass-through between your application and the Cardano wallet, using specific application characteristics and properties.

The ***required*** parameter for implementing this trait is:
 - `network`: Defines the network choice for the Cardano Wallet. The available options are "preview", "preprod" and "mainnet".

This configuration effectively attaches specific volumes to each container that is part of your application. Also, a `socat` container bridges the Cardano Wallet and the Cardano Node by utilizing TCP Socket over a UNIX Socket.

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


