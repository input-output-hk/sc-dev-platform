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
    profile install $INCLUDED_FLAKE_URIS nixpkgs\#bash


# Copy the Nix store closure into a directory. The Nix store closure is the
# entire set of Nix store values that we need for our build.
RUN mkdir -p /workspace/tmp/nix-store-closure
RUN cp -R $(nix-store -qR /workspace/tmp/build/.nix-profile) /workspace/tmp/nix-store-closure
RUN cp /workspace/tmp/build/.nix-profile/bin/$ENTRYPOINT_BIN_NAME /workspace/tmp/build/entrypoint
RUN rm -fR /nix

# Final image is based on scratch. We copy a bunch of Nix dependencies
# but they're fully self-contained so we don't need Nix anymore.
FROM scratch

WORKDIR /workspace/tmp

# Copy /nix/store
COPY --from=builder /workspace/tmp/nix-store-closure /nix/store
COPY --from=builder /workspace/tmp/build/.nix-profile /
COPY --from=builder /workspace/tmp/build/entrypoint /entrypoint
CMD ["/entrypoint"]
