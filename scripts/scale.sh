#!/bin/bash

# Function to display an error message and exit
error_exit() {
  echo "Error: $1" >&2
  exit 1
}

# Check if the required command-line arguments are provided
if [ $# -ne 3 ]; then
  error_exit "Usage: $0 <environment> <cluster> <namespace>"
fi

env=$1
cluster=$2
namespace=$3

# Check if the 'terraform' command is available
if ! command -v terraform &>/dev/null; then
  error_exit "'terraform' command not found. Please install Terraform."
fi

cluster_location=$(pwd)/infra/us-east-1/$env/eks/$cluster/eks
eks_cluster_name=$(basename "$(cd "$cluster_location" && terragrunt output cluster_name)" | sed 's/"//g')


aws eks --region us-east-1 update-kubeconfig --name "$eks_cluster_name"

read -p "Do you want to scale the indexer up? (y/n):" scale_context

if [[ $scale_context == "y" || $scale_context == "Y"]]; then
    kubectl --context "$eks_cluster_name" -n $namespace get deploy -oname | grep indexer | while read -r deploy; do 
    kubectl --context scde-prod-blue -n $namespace scale $deploy --replicas=1; done
    echo "Indexer is scaled to 1 in $namespace"
else
    kubectl --context "$eks_cluster_name" -n $namespace get deploy -oname | grep indexer | while read -r deploy; do 
    kubectl --context scde-prod-blue -n $namespace scale $deploy --replicas=0; done
    echo "Indexer is scaled to 0 in $namespace"
fi

