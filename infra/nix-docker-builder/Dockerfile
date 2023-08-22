# Nix builder
FROM nixos/nix:latest AS builder
ARG ENTRYPOINT_BIN_NAME=bash
ARG INCLUDED_FLAKE_URIS

WORKDIR /workspace/tmp/build

# Build our Nix environment
RUN HOME=/workspace/tmp/build nix \
    --extra-experimental-features "nix-command flakes" \
    --option filter-syscalls false \
    --accept-flake-config \
    profile install $INCLUDED_FLAKE_URIS nixpkgs\#bash nixpkgs\#coreutils nixpkgs\#cacert


# Copy the Nix store closure into a directory. The Nix store closure is the
# entire set of Nix store values that we need for our build.
RUN mkdir -p /workspace/tmp/root/nix/store
RUN cp -R $(nix-store -qR /workspace/tmp/build/.nix-profile) /workspace/tmp/root/nix/store
RUN cp /workspace/tmp/build/.nix-profile/bin/$ENTRYPOINT_BIN_NAME /workspace/tmp/root/entrypoint
RUN cp -a /workspace/tmp/build/.nix-profile/bin /workspace/tmp/root/bin
# /etc may be a symlink in the nix profile, but can't be on the image filesystem (the runtime needs to set up e.g. resolv.conf)
RUN mkdir -p /workspace/tmp/root/etc
RUN cp -a /workspace/tmp/build/.nix-profile/etc/* /workspace/tmp/root/etc
RUN cp -a $(readlink -f /workspace/tmp/build/.nix-profile) /workspace/tmp/root/profile
RUN rm -fR /nix

# Final image is based on scratch. We copy a bunch of Nix dependencies
# but they're fully self-contained so we don't need Nix anymore.
FROM scratch

WORKDIR /tmp

COPY --from=builder /workspace/tmp/root /
ENTRYPOINT ["/entrypoint"]
