FROM debian:sid-20251020-slim
LABEL maintainer="Julien Rialland <julien.rialland@gmail.com>"

# Add 32-bit architecture for Wine
RUN dpkg --add-architecture i386

# Install Wine and dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq
RUN apt-get install -qq -y ca-certificates file curl unzip wine32:i386 wine64
RUN apt-get clean

ENV XDG_RUNTIME_DIR=/tmp/runtime
RUN mkdir -p /tmp/runtime

# Set up Wine for 64-bit Windows applications
RUN mkdir -p /wine64
ENV WINEPREFIX=/wine64
ENV WINEARCH=win64
#ENV WINEDEBUG=-all
RUN winecfg /v win11

# Download and run the Python installer
ENV EXPECTED_SHA256=c0f3b1a2809106f4a1a2260ba9d7421fe84b820593c51e818fc5da4f475ff54e
RUN curl -s -LO "https://github.com/winpython/winpython/releases/download/17.2.20250920final/WinPython64-3.13.7.0dot.zip"
# Verify the SHA256 checksum
RUN echo "${EXPECTED_SHA256}  WinPython64-3.13.7.0dot.zip" | sha256sum -c -

# Unzip WinPython
RUN unzip -q "WinPython64-3.13.7.0dot.zip" -d /wine64/drive_c/WinPython

# check the path of python.exe
RUN file /wine64/drive_c/WinPython/WPy64-31700/python/python.exe
ENV WINPYTHON_PATH="C:\\WinPython\\WPy64-31700\\python"
RUN wine reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "${WINPYTHON_PATH};${WINPYTHON_PATH}\\Scripts;%PATH%" /f

RUN echo 'wine "${WINPYTHON_PATH}\\python.exe" "$@"' > /usr/local/bin/wine-python
RUN chmod +x /usr/local/bin/wine-python
RUN ln -s /usr/local/bin/wine-python /usr/local/bin/python

RUN echo 'wine "${WINPYTHON_PATH}\\Scripts\\pip.exe" "$@"' > /usr/local/bin/wine-pip
RUN chmod +x /usr/local/bin/wine-pip
RUN ln -s /usr/local/bin/wine-pip /usr/local/bin/pip

# Check that Python is installed correctly
RUN wine-python --version

# Make ssl work
RUN update-ca-certificates
RUN mkdir -p ${WINEPREFIX}/drive_c/WinPython/WPy64-31700/sites-packages/certifi
RUN cat /etc/ssl/certs/*.pem /etc/ssl/certs/*.crt > ${WINEPREFIX}/drive_c/WinPython/WPy64-31700/sites-packages/certifi/cacert.pem
ENV SSL_CERT_FILE="C:\\WinPython\\WPy64-31700\\python\\Lib\\site-packages\\certifi\\cacert.pem"
RUN wine reg add "HKCU\\Software\\Wine\\WineTLS" /v CA_BUNDLE /t REG_SZ /d ${SSL_CERT_FILE} /f

# disable Wine debug messages
ENV WINEDEBUG=-all

WORKDIR /wine64/drive_c
CMD ["wine", "${WINPYTHON_PATH}\\python.exe"]