{ pkgs, inputs' }@args: {
  kubevela = pkgs.callPackage ./kubevela.nix { };
}
