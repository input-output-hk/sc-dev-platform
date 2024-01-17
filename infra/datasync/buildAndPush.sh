#!/bin/bash

# Step 1: Build Docker Image
DOCKER_IMAGE="data-sync:$(date +%Y%m%d)"
docker build -t $DOCKER_IMAGE . --platform=linux/amd64

# Step 2: AWS ECR Login
export AWS_PROFILE=dapps-world
account_id=$(aws sts get-caller-identity --output text --query 'Account')
region=$(aws configure get region)
ecr_registry="${account_id}.dkr.ecr.${region}.amazonaws.com"

aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${account_id}.dkr.ecr.${region}.amazonaws.com

# Step 3: Tag Docker Image
docker tag $DOCKER_IMAGE ${ecr_registry}/$DOCKER_IMAGE

# Step 4: Push Docker Image
docker push ${ecr_registry}/$DOCKER_IMAGE