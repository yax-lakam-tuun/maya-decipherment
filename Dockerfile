FROM ubuntu:22.04

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y texlive-full inkscape git git-lfs

ARG user_name="vscode"
RUN useradd -m $user_name

USER $user_name
