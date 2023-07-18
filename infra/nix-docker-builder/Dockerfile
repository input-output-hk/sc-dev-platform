# Nix builder
FROM nixos/nix:latest AS builder
ARG ENTRYPOINT_BIN_NAME=bash
ARG INCLUDED_FLAKE_URIs

WORKDIR /tmp/build

# Build our Nix environment
RUN HOME=/tmp/build nix \
    --extra-experimental-features "nix-command flakes" \
    --option filter-syscalls false \
    --accept-flake-config \
    profile install $INCLUDED_FLAKE_URIS nixpkgs\#bash


# Copy the Nix store closure into a directory. The Nix store closure is the
# entire set of Nix store values that we need for our build.
RUN mkdir /tmp/nix-store-closure
RUN cp -R $(nix-store -qR /tmp/build/.nix-profile) /tmp/nix-store-closure
RUN cp /tmp/build/.nix-profile/bin/$ENTRYPOINT_BIN_NAME /tmp/build/entrypoint

# Final image is based on scratch. We copy a bunch of Nix dependencies
# but they're fully self-contained so we don't need Nix anymore.
FROM scratch

WORKDIR /tmp

# Copy /nix/store
COPY --from=builder /tmp/nix-store-closure /nix/store
COPY --from=builder /tmp/build/.nix-profile /
COPY --from=builder /tmp/build/entrypoint /entrypoint
CMD ["/entrypoint"]
