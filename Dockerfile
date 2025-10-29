FROM ubuntu:25.04
LABEL maintainer="Julien Rialland <julien.rialland@gmail.com>"

# Add 32-bit architecture for Wine
RUN dpkg --add-architecture i386

# Install Wine and dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq
RUN apt-get install -qq -y ca-certificates file curl unzip wine64
RUN apt-get clean

# Set up Wine for 64-bit Windows applications
RUN mkdir -p /wine64
ENV WINEPREFIX=/wine64
ENV WINEARCH=win64
ENV WINEDEBUG=-all
RUN winecfg /v win11

# Download and run the Python installer
ENV EXPECTED_SHA256=c0f3b1a2809106f4a1a2260ba9d7421fe84b820593c51e818fc5da4f475ff54e
RUN curl -q -LO "https://github.com/winpython/winpython/releases/download/17.2.20250920final/WinPython64-3.13.7.0dot.zip"
# Verify the SHA256 checksum
RUN echo "${EXPECTED_SHA256}  WinPython64-3.13.7.0dot.zip" | sha256sum -c -

# Unzip WinPython
RUN unzip -q "WinPython64-3.13.7.0dot.zip" -d /wine64/drive_c/WinPython

# check the path of python.exe
RUN file /wine64/drive_c/WinPython/WPy64-31700/python/python.exe

# Add Python to PATH in the Wine environment
RUN wine reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "C:\\WinPython\\WPy64-31700\\python;C:\\WinPython\\WPy64-31700\\python\\Scripts;%PATH%" /f

# Check that Python is installed correctly
RUN wine "C:\\WinPython\\WPy64-31700\\python.exe" --version

# Use pip to install additional Python packages
RUN wine "C:\\WinPython\\WPy64-31700\\Scripts\\pip.exe" install --upgrade pip setuptools wheel