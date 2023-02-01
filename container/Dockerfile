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
RUN apt-get -qq install git git-lfs inkscape python3 vim zsh curl wget

# Devcontainers need a pre-defined user called 'vscode'
ARG user_name="ajtzib"
RUN useradd -m -k /etc/skel -d /home/$user_name $user_name

# Install ohmyzsh for vscode user
USER $user_name
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    cp /home/$user_name/.oh-my-zsh/templates/zshrc.zsh-template /home/$user_name/.zshrc
    
# Github runners run as root by default, so let's switch back here to avoid perimission problems
USER root
