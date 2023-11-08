# Start devenv Module here
# self' for accessing packages and self for flake path
{ pkgs, self', self, ... }:
{
  packages = with pkgs; [
    kubectl
    self'.packages.kubevela
    cue
    kubernetes-helm
  ];
  env = {
    KUBECONFIG = "${self}/infra/kubeconfig-dapps-prod-us-east-1:${self}/infra/kubeconfig-scde-prod-us-east-1-blue";
  };
}
