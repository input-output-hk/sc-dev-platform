{ pkgs, ... }:
{
  packages = with pkgs; [
    awscli
    sops
    terraform
    terragrunt
    kubectl
  ];
  env = {
    # dapps-world is still the account name in aws
    AWS_PROFILE = "dapps-world";
    # This is where eks cluster is located
    AWS_DEFAULT_REGION = "us-east-1";
  };
}
