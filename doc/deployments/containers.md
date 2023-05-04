# Containers

## Summary
Every deployment will need containers for each component. The current way to setup containers is with nix and the [standard][std] library's `mkOperable` and `mkStandardOCI`. An operable is the entrypoint for the container or the script that will be run on container startup along with all the needed dependencies. `mkStandardOCI` will take an operable and build an OCI image with it.

*Note:* This process of making containers is planned to change in order to be more friendly and require less boilerplate.

## Setup
If you are working in a standardized repository, then you can follow the setups described in this [video][std-oci-video] . Otherwise you will need to manually setup the scaffolding with the following steps.

Start by creating an `operables.nix` and `oci-images.nix` which are typically placed in a `deploy` folder at the root of the repository.
You can initialize `operables.nix` with a header like this:
```nix
{ inputs }:
let
  inherit (inputs) self std nixpkgs;
  inherit (self) packages;
  inherit (nixpkgs) lib;
  inherit (nixpkgs.legacyPackages)
    coreutils
    # Further runtime inputs can be imported here
    ;
  inherit (std.lib.ops) mkOperable;
in {
  /*
  cardano-node = mkOperable {
    package = packages.cardano-node;
    runtimeInputs = [ jq coreutils ];
    runtimeScript = ''
      ${packages.cardano-node}/bin/cardano-node
    '';
  };
  */
  # Operables can be added here in a similar format
}
```
And `oci-images.nix` with:
```nix
{ inputs }:
let
  inherit (inputs) std self nixpkgs;
  inherit (nixpkgs.lib) removePrefix mapAttrsToList mapAttrs;
  inherit (nixpkgs.lib.strings) concatMapStrings;
  inherit (self) operables;
  inherit (self.sourceInfo) lastModifiedDate;

  mkImage = { name, description }:
    std.lib.ops.mkStandardOCI {
      inherit name;
      tag = "latest";
      operable = operables.${name};
      uid = "0";
      gid = "0";
      labels = {
        inherit description;
        # source = "";
        # license = "";
      };
    };

  images = {
    /*
    cardano-node = mkImage {
      name = "cardano-node";
      description = "The core component that is used to participate in a Cardano decentralised blockchain.";
    };
    */
    # Names each image and descriptions can be added here
  };

  forAllImages = f: concatMapStrings (s: s + "\n") (mapAttrsToList (_: f) images);
in
images // {
  # Helpful attribute to build and copy all images
  all = {
    copyToDockerDaemon = std.lib.ops.writeScript {
      name = "copy-to-docker-daemon";
      text = forAllImages (img: "${img.copyToDockerDaemon}/bin/copy-to-docker-daemon");
    };
  };
}
```

Then to export both you can add the following lines wherever you export system-spaced outputs (when using flake-utils this would be inside the attrset passed to `eachSystem`):
```nix
operables = import ./deploy/operables.nix {
  inputs = nosys.lib.deSys system inputs;
};
oci-images = import ./deploy/oci-images.nix {
  inputs = nosys.lib.deSys system inputs;
};
```

For all this to work, you will need to add [nosys][nosys] and [std][std] as flake inputs.


[standard]: https://github.com/divnix/std
[nosys]: https://github.com/divnix/nosys
[std-oci-video]: https://www.loom.com/share/27d91aa1eac24bcaaaed18ea6d6d03ca
