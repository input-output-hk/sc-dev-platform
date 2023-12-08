#!/bin/bash

env=$1
cluster=$2

cluster_location=$(pwd)/infra/us-east-1/$env/eks/$cluster/eks
eks_cluster_name=$(basename $(cd $cluster_location && terragrunt output cluster_name) | sed 's/"//g')

echo "Updating KUBECONFIG for EKS cluster: $eks_cluster_name"

kube_config_path="./infra/kube.config"

read -p "Do you want to delete the current context? (y/n): " delete_context

if [[ $delete_context == "y" || $delete_context == "Y" ]]; then
  # Delete the specified context
  kubectl config delete-context "$eks_cluster_name"
  echo "Context '$eks_cluster_name' deleted from kubeconfig."
else
  # Update or create kubeconfig
  aws eks --region us-east-1 update-kubeconfig --name "$eks_cluster_name" --kubeconfig "$kube_config_path"
  echo "KUBECONFIG updated in the Nix expression for EKS cluster: $eks_cluster_name"
fi