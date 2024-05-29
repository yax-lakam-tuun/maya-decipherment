FROM ubuntu:22.04

# Disable Debian front-end during installations
ARG DEBIAN_FRONTEND="noninteractive"

# Update/upgrade image
RUN apt-get -qq update && \
    apt-get -qq upgrade

# Set correct locale (which might be need by LuaLatex)
RUN apt-get -qq install locales && \
    echo "en_US.UTF-8 UTF-8" | tee -a /etc/locale.gen && \
    locale-gen

# Install Tex environment
RUN apt-get -qq install texlive-full chktex

# Install tools and other useful gadgets
RUN apt-get -qq install \
        git git-lfs \
        inkscape vim \
        curl wget \
        apt-transport-https software-properties-common

# Install PowerShell
ARG TARGETPLATFORM
RUN curl -L -o /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/powershell-7.4.2-$(echo "$TARGETPLATFORM" | sed 's/amd64/x64/g' | sed 's/\//-/g').tar.gz && \
    mkdir -p /opt/microsoft/powershell/7 && \
    tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 && \
    chmod +x /opt/microsoft/powershell/7/pwsh && \
    ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh && \
    pwsh -Command "Install-Module posh-git -Scope AllUsers -Force" && \
    pwsh -Command "Add-PoshGitToProfile -AllUsers -AllHosts"

# Dev Containers need a pre-defined user called 'vscode'
ARG user_name="ajtzib"
RUN useradd -m -k /etc/skel -d /home/$user_name $user_name
 
# Github runners run as root by default to avoid perimission problems
USER root

# Compile document when container is executed with defaults
SHELL [ "pwsh" ]
CMD ["pwsh", "-Command", "/opt/sources/Compile-Document.ps1 -DocumentName \"Maya Hieroglyphs - The History of Decipherment\""]