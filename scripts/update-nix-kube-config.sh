#!/bin/bash

read -p "Which env is this for? (dev, prod): " env
read -p "Which cluster is this for? (green, blue): " cluster

cluster_location=$(pwd)/infra/us-east-1/$env/eks/$cluster/eks
eks_cluster_name=$(basename $(cd $cluster_location && terragrunt output cluster_name) | sed 's/"//g')

echo "Updating KUBECONFIG for EKS cluster: $eks_cluster_name"

kube_config_path="./infra/kube.config"

aws eks --region us-east-1 update-kubeconfig --name "$eks_cluster_name" --kubeconfig "$kube_config_path"

echo "KUBECONFIG updated in the Nix expression for EKS cluster: $eks_cluster_name"