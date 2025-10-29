FROM ubuntu:25.04
LABEL maintainer="Julien Rialland <julien.rialland@gmail.com>"

# Add 32-bit architecture for Wine
RUN dpkg --add-architecture i386

# Install Wine and dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y ca-certificates curl unzip wine64
RUN apt-get clean

# Set up Wine for 64-bit Windows applications
RUN mkdir -p /wine64
ENV WINEPREFIX=/wine64
ENV WINEARCH=win64
ENV WINEDEBUG=-all
RUN winecfg /v win11

# Download and run the Python installer
RUN curl -q -LO "https://github.com/winpython/winpython/releases/download/17.2.20250920final/WinPython64-3.13.7.0dot.zip"
RUN unzip "WinPython64-3.13.7.0dot.zip" -d /wine64/drive_c/WinPython

# Add Python to PATH in the Wine environment
RUN wine reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "C:\WinPython\WPy64-31700\python-3.13.7.amd64;C:\WinPython\WPy64-31700\Scripts;%PATH%" /f

# Check that Python is installed correctly
RUN wine python --version

# Use pip to install additional Python packages
RUN wine pip install --upgrade pip setuptools wheel