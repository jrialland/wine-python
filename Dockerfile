FROM ubuntu:25.04
LABEL maintainer="Julien Rialland <julien.rialland@gmail.com>"

ENV PYTHON_VERSION=3.13.9

# Add 32-bit architecture for Wine
RUN dpkg --add-architecture i386

# Install Wine and dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y ca-certificates curl unzip wine64 winetricks xvfb
RUN apt-get clean

# Set up Wine for 64-bit Windows applications
RUN mkdir -p /wine64
ENV WINEPREFIX=/wine64
ENV WINEARCH=win64
ENV WINEDEBUG=-all
RUN winecfg /v win11

# winetricks to install some necessary components
RUN winetricks -q crypt32 urlmon wininet winhttp
RUN mkdir -p /tmp/helper

# Download and verify Python installer
RUN --mount=from=ghcr.io/sigstore/cosign/cosign:v3.0.2@sha256:b29487e48205d875c324c79583e2806d9d269c0fa299e0861bbec023d8430c8b,source=/ko-app/cosign,target=/usr/bin/cosign \
  umask 0 && cd /tmp/helper && \
  curl --fail-with-body -LOO "https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-amd64.exe{,.sigstore}" \
  && \
  xvfb-run sh -c "\
    wine python-${PYTHON_VERSION}-amd64.exe /quiet TargetDir=C:\\Python \
      Include_doc=0 InstallAllUsers=1 PrependPath=1; \
    wineserver -w"
    
# Verify installations
RUN wine python --version
RUN wine pip --version