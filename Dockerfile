FROM ubuntu:25.04
LABEL maintainer="Julien Rialland <julien.rialland@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y curl unzip wine64
RUN apt-get clean

# Download the official Python installer for Windows
RUN curl -o /tmp/python-installer.exe https://www.python.org/ftp/python/3.13.9/python-3.13.9-amd64.exe

# Install Python silently under Wine
RUN wine /tmp/python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

# Remove installer
RUN rm /tmp/python-installer.exe

# Verify installation
RUN wine "C:\\Program Files\\Python313\\python.exe" --version

# Install pip and basic build tools
RUN wine "C:\\Program Files\\Python313\\python.exe" -m pip install --upgrade pip setuptools wheel

# Install pyinstaller
RUN wine "C:\\Program Files\\Python313\\python.exe" -m pip install pyinstaller