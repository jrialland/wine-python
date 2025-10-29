FROM ubuntu:25.04
LABEL maintainer="Julien Rialland <julien.rialland@gmail.com>"

# Add 32-bit architecture for Wine
RUN dpkg --add-architecture i386

# Install Wine and dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y curl unzip wine64
RUN apt-get clean

# Set up Wine for 64-bit Windows applications
RUN mkdir -p /wine64
ENV WINEPREFIX=/wine64
ENV WINEARCH=win64
RUN winecfg /v win11

# Download the official Python installer for Windows
RUN curl -o /tmp/python-installer.msi https://www.python.org/ftp/python/3.13.9/python-3.13.9-amd64.msi

# Install Python silently under Wine
RUN wine msiexec /i /tmp/python-installer.msi /qn

# Remove installer
RUN rm /tmp/python-installer.msi

# Verify installation
RUN wine "C:\\Program Files\\Python313\\python.exe" --version

# Install pip and basic build tools
RUN wine "C:\\Program Files\\Python313\\python.exe" -m pip install --upgrade pip setuptools wheel

# Install pyinstaller
RUN wine "C:\\Program Files\\Python313\\python.exe" -m pip install pyinstaller