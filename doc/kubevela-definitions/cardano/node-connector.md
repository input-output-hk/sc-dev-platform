# Cardano Node Connector trait

## Overview

The Cardano Node Connector in Kubvela acts as a bridge between your application and the Cardano node through specific application characteristics and settings

The ***required*** parameter for implementing this trait is:
 - `network`: Defines the network choice for the Cardano Node, with a default setting as "preview". 
<br>The other options available are "preprod" and "mainnet".

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
