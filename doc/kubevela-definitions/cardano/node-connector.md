# Cardano Node Connector trait

## Overview

The Cardano Node Connector in Kubvela acts as a bridge between your application and the Cardano node through specific application characteristics and settings

The ***required*** parameter for implementing this trait is:
 - `network`: Defines the network choice for the Cardano Node. The available options are "preview", "preprod" and "mainnet".

This configuration effectively attaches specific volumes to each container that is part of your application. Also, a `socat` container bridges your application and the Cardano Node by utilizing TCP Socket over a UNIX Socket.

## Usage

An instance of how you can utilize this trait within a Kubvela application follows:

```yaml
apiVersion: core.oam.dev/v1beta1
kind: Application
metadata:
  name: oura
  namespace: oura
spec:
  components:
  - name: oura
    type: webservice
    properties:
      image: alexfalcucci/oura:2.0.1
      args:
      - daemon
      imagePullPolicy: Always
    traits:
    - type: cardano-node-connector
      properties:
        network: preview
```

Once this Application definition is applied, the socket will be available in `/ipc/node.socket` which is mounted through an emptyDir volume and shared between the containers. Please note the socket path is also available on `CARDANO_NODE_SOCKET_PATH` environment variable.


