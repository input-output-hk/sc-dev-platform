Allocate volumes using OAM definition
===============

This document covers the capability to declaratively allocate state using AWS [EBS](https://aws.amazon.com//ebs/) (Elastic Block Store) volumes for persistent data and [Kubernetes Ephemeral Volumes](https://kubernetes.io/docs/concepts/storage/ephemeral-volumes/) for volatile data.


Attaching a persistent volume
---------------

This capability uses [aws-ebs-csi-driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) addon to create cloud resources using straightforward Application definitions from OAM/kubeVela. To request and attach a new EBS volume we can use the *storage* trait definition as shown below:

```yaml
apiVersion: core.oam.dev/v1beta1
kind: Application
metadata:
  name: test-ebs
  namespace: default
spec:
  components:
  - name: test-ebs
    properties:
      cpu: "1"
      exposeType: ClusterIP
      image: nginx
      memory: 1024Mi
      ports:
      - expose: true
        port: 80
        protocol: TCP
    traits:
    - type: scaler
      properties:
        replicas: 1
    - type: storage
      properties:
      # This will create a persistentVolumeClaim mapped to "ebs-sc" storageClass 
      # ebs-sc is managed by aws-ebs-csi-driver and requests a KMS encrypted gp3 volume by default
        pvc:
        - name: test-ebs
        # The new volume will be mounted on /store directory of the container file system
          mountPath: /store
          storageClassName: ebs-sc
          resources:
            requests:
              storage: 5Gi
    type: webservice
```


Attaching an ephemeral volume
---------------

If we have to store data that is easily reproducible or even disposable, we can use this feature by adding a `volumeMounts` block in the component definition, as follows:

```yaml
apiVersion: core.oam.dev/v1beta1
kind: Application
metadata:
  name: test-ebs
  namespace: default
spec:
  components:
  - name: test-ebs
    properties:
      cpu: "1"
      exposeType: ClusterIP
      image: nginx
      memory: 1024Mi
      ports:
      - expose: true
        port: 80
        protocol: TCP
      # The object below will create an empty directory in the node's filesystem
      # This directory will be mapped to a Pod
      volumeMounts:
        emptyDir:
        - name: disposable
          mountPath: /mnt
      ####
    traits:
    - type: scaler
      properties:
        replicas: 1
    type: webservice
```
The `emptyDir.medium` field controls where `emptyDir` volumes are stored. By default `emptyDir` volumes are stored on whatever medium that backs the node such as disk, SSD, or network storage, depending on your environment. If you set the `emptyDir.medium` field to "Memory", Kubernetes mounts a `tmpfs` (RAM-backed filesystem) for you instead. While `tmpfs` is very fast be aware that, unlike disks, files you write count against the memory limit of the container that wrote them.

**⚠️ IMPORTANT**!

When a pod is removed from a node for any reason, the data in the `emptyDir` is deleted permanently. A container crashing does not removed a pod from a node so the data in an `emptyDir` volume is safe across container crashs. This volume shouldn’t be used to store unreproducible data, it's more suitable for caching and/or storing temporary files. If you need to store unreproducible and persistent data, use persistent volume claims (EBS volumes).