#!/bin/bash

# Prompt the user for the EKS cluster name
read -p "Enter the EKS cluster name: " eks_cluster_name


kube_config_path="./infra/kube.config"

aws eks --region us-east-1 update-kubeconfig --name "$eks_cluster_name" --kubeconfig "$kube_config_path"

echo "KUBECONFIG updated in the Nix expression for EKS cluster: $eks_cluster_name"
