FROM ubuntu:25.04
LABEL maintainer="Julien Rialland <julien.rialland@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y curl unzip wine64
RUN apt-get clean

# Download python for windows and unzip it
RUN curl -o /tmp/python.zip https://www.python.org/ftp/python/3.13.9/python-3.13.9-embed-amd64.zip
RUN unzip /tmp/python.zip -d /opt/python-windows
RUN rm /tmp/python.zip
RUN wine /opt/python-windows/python.exe --version

# Install pip and basic build tools
RUN wine /opt/python-windows/python.exe -m ensurepip
RUN wine /opt/python-windows/python.exe -m pip install --upgrade pip setuptools wheel

# Install pyinstaller
RUN wine /opt/python-windows/python.exe -m pip install pyinstaller