#!/bin/bash

# Function to display an error message and exit
error_exit() {
  echo "Error: $1" >&2
  exit 1
}

# Check if the required command-line arguments are provided
if [ $# -ne 2 ]; then
  error_exit "Usage: $0 <environment> <cluster>"
fi

env=$1
cluster=$2

# Check if the 'terraform' command is available
if ! command -v terraform &>/dev/null; then
  error_exit "'terraform' command not found. Please install Terraform."
fi

cluster_location=$(pwd)/infra/us-east-1/$env/eks/$cluster/eks
eks_cluster_name=$(basename "$(cd "$cluster_location" && terragrunt output cluster_name)" | sed 's/"//g')

# Check if the 'kubectl' command is available
if ! command -v kubectl &>/dev/null; then
  error_exit "'kubectl' command not found. Please install kubectl."
fi

echo "Updating KUBECONFIG for EKS cluster: $eks_cluster_name"

kube_config_path="./infra/kube.config"

read -p "Do you want to delete the current context? (y/n): " delete_context

if [[ $delete_context == "y" || $delete_context == "Y" ]]; then
  # Delete the specified context
  kubectl config delete-context "$eks_cluster_name" || error_exit "Failed to delete the context."
  echo "Context '$eks_cluster_name' deleted from kubeconfig."
else
  # Update or create kubeconfig
  aws eks --region us-east-1 update-kubeconfig --name "$eks_cluster_name" --kubeconfig "$kube_config_path" || error_exit "Failed to update kubeconfig."
  echo "KUBECONFIG updated in the Nix expression for EKS cluster: $eks_cluster_name"
fi