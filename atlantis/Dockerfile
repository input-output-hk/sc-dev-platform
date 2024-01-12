ARG ATLANTIS_VERSION=0.26.0

# https://github.com/aws/aws-cli/tags
ARG AWS_CLI_VERSION=2.10.0

# https://hub.docker.com/_/python/tags?page=1&name=alpine
ARG PYTHON_ALPINE_VERSION=3.10.7-alpine3.16

FROM python:${PYTHON_ALPINE_VERSION} as builder

ARG AWS_CLI_VERSION
RUN apk add --no-cache \
    git \
    unzip \
    groff \
    build-base \
    libffi-dev \
    cmake \
    && git clone \
    --single-branch \
    --depth 1 \
    -b ${AWS_CLI_VERSION} \
    https://github.com/aws/aws-cli.git

WORKDIR /aws-cli
RUN python -m venv venv \
    && . venv/bin/activate \
    && scripts/installers/make-exe \
    && unzip -q dist/awscli-exe.zip \
    && aws/install --bin-dir /aws-cli-bin \
    && /aws-cli-bin/aws --version

# reduce image size: remove autocomplete and examples
RUN rm -rf \
    /usr/local/aws-cli/v2/current/dist/aws_completer \
    /usr/local/aws-cli/v2/current/dist/awscli/data/ac.index \
    /usr/local/aws-cli/v2/current/dist/awscli/examples \
    && find /usr/local/aws-cli/v2/current/dist/awscli/botocore/data \
    -name examples-1.json \
    -delete

# build the final image
FROM ghcr.io/runatlantis/atlantis:v${ATLANTIS_VERSION}

COPY --from=builder /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=builder /aws-cli-bin/ /usr/local/bin/