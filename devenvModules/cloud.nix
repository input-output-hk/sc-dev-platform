# Start devenv Module here
# self' for accessing packages and self for flake path
{
  pkgs,
  self',
  self,
  ...
}: {
  packages = with pkgs; [
    kubectl
    self'.packages.kubevela
    cue
    kubernetes-helm
    kustomize
  ];
  env = {
    KUBECONFIG = "${self}/infra/kube.config";
  };
}
