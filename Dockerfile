FROM ubuntu:25.04
LABEL maintainer="Julien Rialland <julien.rialland@gmail.com>"

# Add 32-bit architecture for Wine
RUN dpkg --add-architecture i386

# Install Wine and dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y curl unzip wine64 winetricks
RUN apt-get clean

# Set up Wine for 64-bit Windows applications
RUN mkdir -p /wine64
ENV WINEPREFIX=/wine64
ENV WINEARCH=win64
ENV WINEDEBUG=-all
RUN winecfg /v win11

# winetricks : ssl backend
RUN winetricks -q crypt32
RUN winetricks -q winhttp
RUN winetricks -q wininet

# Download the official Python installer for Windows
RUN curl -s -o /tmp/python-embedder.zip https://www.python.org/ftp/python/3.13.9/python-3.13.9-embed-amd64.zip
RUN unzip /tmp/python-embedder.zip -d /wine64/drive_c/Python313
RUN rm /tmp/python-embedder.zip

# Configure Python ._pth file to include site-packages
RUN echo 'import site' >> /wine64/drive_c/Python313/python313._pth
RUN echo 'site.addsitedir("C:\\\\Python313\\\\Lib\\\\site-packages")' >> /wine64/drive_c/Python313/python313._pth

# install pip
RUN curl -s -o /wine64/drive_c/Python313/get-pip.py https://bootstrap.pypa.io/get-pip.py
RUN wine "C:\\Python313\\python.exe" "C:\\Python313\\get-pip.py"

# modify PATH in wine registry to include Python and Scripts directories
RUN wine reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "C:\Python313;C:\Python313\Scripts;%PATH%" /f

# Verify installations
RUN wine python --version
RUN wine pip --version