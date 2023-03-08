# Start devenv Module here
{ pkgs, self', ... }:
{
  packages = with pkgs; [
    kubectl
    self'.packages.kubevela
  ];
}
