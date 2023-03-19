{ inputs }:
{
  metal = import ./metal.nix;
  cloud = import ./cloud.nix { inherit inputs; };
}
