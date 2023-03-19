{ inputs }:

# Start devenv module here
{ pkgs, ... }:
{
  packages = with pkgs; [
    kubectl
    inputs.self.packages.${pkgs.system}.kubevela
  ];
}
