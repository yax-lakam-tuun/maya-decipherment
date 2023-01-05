FROM ubuntu:22.04

# Disable Debian front-end during installations
ARG DEBIAN_FRONTEND="noninteractive"

# Set correct locale (which might be need by LuaLatex)
RUN apt-get -qq update && \
    apt-get -qq upgrade && \
    apt-get -qq install locales && \
    echo "en_US.UTF-8 UTF-8" | tee -a /etc/locale.gen && \
    locale-gen

# Install Tex environment
RUN apt-get -qq update && \
    apt-get -qq upgrade && \
    apt-get -qq install texlive-full chktex

# Install tools and other useful gadgets
RUN apt-get -qq update && \
    apt-get -qq upgrade && \
    apt-get -qq install git git-lfs inkscape python3 vim

# Devcontainers need a pre-defined user called 'vscode'
ARG user_name="vscode"
RUN useradd -m $user_name
