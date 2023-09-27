{
  description = "Smart Contracts Tribe Developer Platform";
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    capsules.url = "github:input-output-hk/devshell-capsules";
    devenv.url = "github:cachix/devenv";
    disko.url = "github:nix-community/disko";
    nixpkgs.url = "github:nixos/nixpkgs";
  };
  outputs = inputs@{ self, flake-parts, devenv, capsules, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];
      # Raw flake outputs (generally not system-dependent)
      flake = {
        devenvModules = import ./devenvModules;
        nixosConfigurations.plutus-bench = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./nixos/ax41-nvme.nix
            {
              system.stateVersion = "23.05";
              hetzner-dedicated.nic = {
                ipv4 = "65.108.236.230";
                netmask4 = 26;
                gateway4 = "65.108.236.193";
                ipv6 = "2a01:4f9:1a:b0de::2";
                netmask6 = 64;
                mac = "a8:a1:59:a2:95:40";
              };
              users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/fJqgjwPG7b5SRPtCovFmtjmAksUSNg3xHWyqBM4Cs shlevy@shlevy-laptop" ];
              networking.nameservers = [ "185.12.64.1" "185.12.64.2" "2a01:4ff:ff00::add:1" "2a01:4ff:ff00::add:2" ];
            }
            ({ pkgs, lib, ... }: {
              environment.systemPackages = [ pkgs.git ];
              # Remove when more actions have node 20 support
              nixpkgs.config.permittedInsecurePackages = [
                "nodejs-16.20.2"
              ];
              nix.settings = {
                max-jobs = 12;
                cores = 0;
                sandbox = true;
                substituters = lib.mkAfter [ "https://cache.iog.io" ];
                trusted-public-keys = [
                  "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
                ];
                trusted-users = [ "root" ];
                builders-use-substitutes = true;
                experimental-features = [ "nix-command" "flakes" ];
                bash-prompt = ''\n\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w \[\033[01;31m\](dev-shell)\[\033[01;32m\]]\$ \[\033[0m\]'';
              };
              services.github-runner = {
                enable = true;
                extraLabels = [ "plutus-benchmark" ];
                name = "plutus-benchmark";
                tokenFile = "/root/runner-pat";
                url = "https://github.com/input-output-hk/plutus";
                nodeRuntimes = [ "node16" "node20" ];
              };
            })
          ];
        };
      };
      # Flake outputs that will be split by system
      perSystem = { config, pkgs, inputs', self', ... }: {
        packages = import ./packages { inherit pkgs inputs'; };

        devShells = {
          default = devenv.lib.mkShell {
            inherit pkgs;
            inputs = inputs // { inherit inputs' self'; };
            modules = [
              self.devenvModules.metal
              self.devenvModules.cloud
            ];
          };
        };
      };
    };
}
