{
  description = "Smart Contracts Tribe Developer Platform";
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    capsules.url = "github:input-output-hk/devshell-capsules";
    devenv.url = "github:cachix/devenv";
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";
  };
  outputs = inputs @ {
    self,
    flake-parts,
    devenv,
    capsules,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];
      # Raw flake outputs (generally not system-dependent)
      flake = {
        devenvModules = import ./devenvModules;
      };
      # Flake outputs that will be split by system
      perSystem = {
        config,
        pkgs,
        inputs',
        self',
        ...
      }: {
        packages = import ./packages {inherit pkgs inputs';};

        devShells = {
          default = devenv.lib.mkShell {
            inherit pkgs;
            inputs = inputs // {inherit inputs' self';};
            modules = [
              self.devenvModules.metal
              self.devenvModules.cloud
            ];
          };
        };
      };
    };
}
