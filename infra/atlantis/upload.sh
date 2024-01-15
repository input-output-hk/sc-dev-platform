#!/bin/bash

# Step 1: Build Docker Image
docker build -t scde . --platform=linux/amd64

# Step 2: AWS ECR Login
account_id=$(aws sts get-caller-identity --output text --query 'Account')
region=$(aws configure get region)
ecr_registry="${account_id}.dkr.ecr.${region}.amazonaws.com"

aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${account_id}.dkr.ecr.${region}.amazonaws.com

# Step 3: Tag Docker Image
docker tag scde:latest ${ecr_registry}/scde:latest

# Step 4: Push Docker Image
docker push ${ecr_registry}/scde:latest

# Additional Tips:
echo "Make sure Docker has experimental features enabled for multi-platform builds."
echo "Ensure AWS CLI is configured with the necessary permissions for Amazon ECR actions."