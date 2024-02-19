```
apiVersion: core.oam.dev/v1beta1
kind: Application
metadata:
  name: private-testnet 
  namespace: private-testnet  
spec:
  components:
  - name: private-testnet 
    type: webservice
    properties:
      exposeType: ClusterIP
      image: alexfalcucci/cardano-node-private-coway:latest
      env:
        - name: NETWORK
          value: "preprod"
        - name: NODE_MODE
          value: "relay"
        - name: PORT
          value: "3001"
        - name: CARDANO_RTS_OPTS
          value: ""
        - name: SB_VRF_SKEY_PATH
          value: ""
        - name: CARDANO_NODE_SOCKET_PATH
          value: "/tmp/db/node.socket"
```;
