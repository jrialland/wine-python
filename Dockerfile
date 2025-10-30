FROM debian:sid-20251020-slim
LABEL maintainer="Julien Rialland <julien.rialland@gmail.com>"

# Add 32-bit architecture for Wine
RUN dpkg --add-architecture i386

# Install curl and unzip
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq
RUN apt-get install -qq -y ca-certificates file curl unzip wine32:i386 wine64 cabextract xdg-utils
RUN wine --version

# Install winetricks
RUN curl -o /usr/local/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
RUN chmod +x /usr/local/bin/winetricks

# Set up a runtime directory
ENV XDG_RUNTIME_DIR=/tmp/runtime
RUN mkdir -p /tmp/runtime
RUN xdg-user-dirs-update

# Set up Wine for 64-bit Windows applications
RUN mkdir -p /wine64
ENV WINEPREFIX=/wine64
ENV WINEARCH=win64
RUN winecfg /v win11

# some wine tweaks
RUN winetricks --self-update
RUN winetricks list-all
RUN winetricks -q crypt32 || true
RUN winetricks -q schannel || true

# Download and install WinPython
RUN curl -s -LO "https://github.com/winpython/winpython/releases/download/17.2.20250920final/WinPython64-3.13.7.0dot.zip"
# Verify the SHA256 checksum
RUN echo "c0f3b1a2809106f4a1a2260ba9d7421fe84b820593c51e818fc5da4f475ff54e  WinPython64-3.13.7.0dot.zip" | sha256sum -c -
RUN unzip -q "WinPython64-3.13.7.0dot.zip" -d /wine64/drive_c/WinPython

# check the path of python.exe
ENV WINPYTHON_PATH="C:\\WinPython\\WPy64-31700\\python"
RUN wine reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "${WINPYTHON_PATH};${WINPYTHON_PATH}\\Scripts;%PATH%" /f

# Create wrappers for python and pip
RUN echo 'wine "${WINPYTHON_PATH}\\python.exe" "$@"' > /usr/local/bin/wine-python
RUN chmod +x /usr/local/bin/wine-python
RUN ln -s /usr/local/bin/wine-python /usr/local/bin/python

RUN echo 'wine "${WINPYTHON_PATH}\\Scripts\\pip.exe" "$@"' > /usr/local/bin/wine-pip
RUN chmod +x /usr/local/bin/wine-pip
RUN ln -s /usr/local/bin/wine-pip /usr/local/bin/pip

# Check that Python is installed correctly
RUN wine-python --version

# Fix SSL
RUN wine-python -m pip --trusted-host pypi.org --trusted-host files.pythonhosted.org install certifi
RUN export SSL_CERT_FILE=$(wine-python -c "import certifi;print(certifi.where())")
RUN echo SSL_CERT_FILE is set to $SSL_CERT_FILE

# disable Wine debug messages
ENV WINEDEBUG=-all
WORKDIR /wine64/drive_c
CMD ["wine", "${WINPYTHON_PATH}\\python.exe"]