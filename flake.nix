{
  description = "Smart Contracts Tribe Developer Platform";
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv";
  };
  outputs = inputs@{ self, flake-parts, devenv, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        devenv.flakeModule
      ];
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];
      # Raw flake outputs (generally not system-dependent)
      flake = {
        devenvModules = import ./devenvModules { inherit inputs; };
      };
      # Flake outputs that will be split by system
      perSystem = { config, pkgs, inputs', self', ... }: {
        packages = import ./packages { inherit pkgs inputs'; };

        devenv.shells = {
          default = {
            imports = [
              self.devenvModules.metal
              self.devenvModules.cloud
            ];
          };
        };
      };
    };
}
