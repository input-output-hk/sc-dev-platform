# Known issues
 - Can't use `terragrunt run-all` for initial setup because of dependency errors
 - apply in k8s/eks might fail on first run because aws-auth configmap doesn't exist, to fix:
    for one run add `create_aws_auth_configmap = true` to terragrunt.hcl in the folder, apply the change, then remove the line to prevent future configmap doesn't exist errors
 - plan in k8s/eks-addons might fail on first run because the cert_issuers.tf reauires cert-manager to already exist, fix by commenting the entire `generate "cert_issuers"` block apply then uncomment and plan/apply
## Steps
 - deploy `vpc`
