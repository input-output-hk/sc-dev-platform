
env=$1
cluster=$2

cluster_location=$(pwd)/infra/us-east-1/$env/eks/$cluster/eks
eks_cluster_name=$(basename "$(cd "$cluster_location" && terragrunt output cluster_name)" | sed 's/"//g')


aws eks --region us-east-1 update-kubeconfig --name "$eks_cluster_name"

kubectl --context arn:aws:eks:us-east-1:677160962006:cluster/scde-dev-us-east-1 -n marlowe-staging get deploy -oname | grep indexer | while read -r deploy; do kubectl --context scde-prod-blue -n marlowe-staging scale $deploy --replicas=0; done