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

This is the output from the Application code above:

```yaml
---
# Application(oura) -- Component(oura)
---

apiVersion: apps/v1
kind: Deployment
metadata:
  annotations: {}
  labels:
    app.oam.dev/appRevision: ""
    app.oam.dev/component: oura
    app.oam.dev/name: oura
    app.oam.dev/namespace: crossplane
    app.oam.dev/resourceType: WORKLOAD
    workload.oam.dev/type: webservice
  name: oura
  namespace: crossplane
spec:
  selector:
    matchLabels:
      app.oam.dev/component: oura
  template:
    metadata:
      labels:
        app.oam.dev/component: oura
        app.oam.dev/name: oura
    spec:
      containers:
      - args:
        - daemon
        env:
        - name: CARDANO_NODE_SOCKET_PATH
          value: /ipc/node.socket
        - name: NODE_CONFIG
          value: /node-config/network/preview/cardano-node/config.json
        image: alexfalcucci/oura:2.0.1
        imagePullPolicy: Always
        name: oura
        volumeMounts:
        - mountPath: /ipc
          name: ipc
      - args:
        - UNIX-LISTEN:/ipc/node.socket,fork
        - TCP-CONNECT:cardano-node-preview.vela-system:8090
        image: alpine/socat
        imagePullPolicy: Always
        name: socat
        volumeMounts:
        - mountPath: /ipc
          name: ipc
      initContainers:
      - args:
        - clone
        - --single-branch
        - --
        - https://github.com/input-output-hk/cardano-configurations
        - /node-config
        image: alpine/git
        imagePullPolicy: Always
        name: node-config-cloner
        volumeMounts:
        - mountPath: /node-config
          name: node-config
      volumes:
      - emptyDir: {}
        name: ipc
      - emptyDir: {}
        name: node-config
```