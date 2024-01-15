# EKS Cluster and Addons

## Overview

This Terragrunt folder is responsible for provisioning and managing an Amazon EKS (Elastic Kubernetes Service) cluster. Additionally, it includes subfolders for various addons to enhance the cluster's capabilities.

## Folder Structure

- `eks/`: Builds the EKS cluster.
- `eks-addons/`: Contains addons specifically tailored for the EKS cluster.
- `grafana-agent/`: Configures Grafana agents for monitoring.
- `kubevela-addons/`: Manages addons related to KubeVela, a modern application delivery platform.

## EKS Cluster Capabilities

The EKS cluster provisioned by this Terragrunt folder includes the following capabilities:

- **Amazon EKS Version**: 1.26
- **Node Groups**: Types: t3a.xlarge

## EKS Addons

### eks-addons Folder

This folder contains additional addons to extend the functionality of the EKS cluster.

- **Addon 1: NGINX Ingress Controller (Public)**

  - **Enabled:** Yes
  - **Load Balancer Name:** prod-green-nginx-public

- **Addon 2: NGINX Ingress Controller (Internal)**

  - **Enabled:** Yes
  - **Load Balancer Name:** prod-green-nginx-internal

- **Addon 3: Cluster Autoscaler**

  - **Enabled:** Yes
  - **Configuration:**
    ```hcl
    cluster_autoscaler = {
      set = [{
        name  = "extraArgs.scale-down-utilization-threshold"
        value = "0.7"
      }]
    }
    ```

- **Addon 4: External-DNS**

  - **Enabled:** Yes
  - **Route53 Zone ARNs:** [List of Route53 Zone ARNs]
  - **Configuration:**
    ```yaml
    env:
      - name: EXTERNAL_DNS_DRY_RUN
        value: "1"
    txtOwnerId: "${dependency.eks.outputs.cluster_name}"
    ```

- **Addon 5: KubeVela Controller**
  - **Enabled:** Yes

### grafana-agent Folder

The `grafana-agent` folder is responsible for configuring Grafana agents to enable monitoring and observability for the EKS cluster.

### kubevela-addons Folder

The `kubevela-addons` folder manages addons that integrate with KubeVela, allowing for modern application delivery and management.

- **Addon A: Crossplane**

  - **Description:** Crossplane is an open-source Kubernetes add-on that extends the Kubernetes API to create and manage infrastructure resources.
  - **YAML Configuration:** `modules/kubevela-addons/addons/crossplane.yaml`

- **Addon B: Dex**

  - **Description:** Dex is an OpenID Connect (OIDC) identity provider that integrates with Kubernetes to provide authentication and authorization services.
  - **YAML Configuration:** `modules/kubevela-addons/addons/dex.yaml`

- **Addon C: FluxCD**

  - **Description:** FluxCD is a continuous delivery tool for Kubernetes that automates the deployment and synchronization of container images.
  - **YAML Configuration:** `modules/kubevela-addons/addons/fluxcd.yaml`

- **Addon D: Kruise Rollout**

  - **Description:** Kruise Rollout is a Kubernetes controller that enhances the deployment process by providing advanced rollout strategies and features.
  - **YAML Configuration:** `modules/kubevela-addons/addons/kruise-rollout.yaml`

- **Addon E: Kube Objects**

  - **Description:** Kube Objects is a collection of custom Kubernetes objects or resources used to define and manage various aspects of a Kubernetes cluster.
  - **YAML Configuration:** `modules/kubevela-addons/addons/kube-objects.yaml`

- **Addon F: VelaUX**
  - **Description:** VelaUX is an extension for KubeVela that provides a graphical user interface (GUI) for managing and deploying applications on Kubernetes.
  - **YAML Configuration:** `modules/kubevela-addons/addons/velaux.yaml`

## Usage

To apply the infrastructure defined in this Terragrunt folder, follow these steps:

1. Navigate to the `eks/` folder: `cd eks/`
2. Initialize Terraform: `terragrunt init`
3. Apply changes: `terragrunt apply`

Repeat the above steps for each addon folder if needed.

To apply to all.

1. Plan all changes: `terragrunt run-all plan`
2. Apply all changes: `terragrunt run-all apply`

## Notes

- [Add any additional notes, considerations, or best practices]
