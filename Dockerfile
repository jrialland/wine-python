FROM ubuntu:25.04
LABEL maintainer="Julien Rialland <julien.rialland@gmail.com>"

# Add 32-bit architecture for Wine
RUN dpkg --add-architecture i386

# Install Wine and dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y ca-certificates curl unzip wine64 winetricks
RUN apt-get clean

# Set up Wine for 64-bit Windows applications
RUN mkdir -p /wine64
ENV WINEPREFIX=/wine64
ENV WINEARCH=win64
ENV WINEDEBUG=-all
RUN winecfg /v win11

# winetricks to install some necessary components
RUN winetricks -q crypt32 urlmon wininet winhttp

# Download the official Python installer for Windows
RUN curl -s -o /tmp/python-installer.exe https://www.python.org/ftp/python/3.13.9/python-3.13.9-amd64.exe

# Install Python silently
RUN wine /tmp/python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

# modify PATH in wine registry to include Python and Scripts directories
#RUN wine reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "C:\Python313;C:\Python313\Scripts;%PATH%" /f

# Verify installations
RUN wine python --version
RUN wine pip --version