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


# Download and run the Python installer
RUN curl --fail-with-body -LOO "https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-amd64.exe"
RUN xvfb-run wine "python-${PYTHON_VERSION}-amd64.exe" /quiet Include_doc=0 InstallAllUsers=1 PrependPath=1 Include_test=0 ; wineserver -w
RUN rm "python-${PYTHON_VERSION}-amd64.exe"

# Verify installations
RUN wine python --version; wineserver -w
RUN wine pip --version; wineserver -w