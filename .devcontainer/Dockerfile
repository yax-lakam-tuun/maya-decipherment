FROM ubuntu:22.04

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y texlive-full inkscape git git-lfs

ARG user_name="vscode"
RUN useradd -m $user_name

ENV tex_file="/opt/sources/main"
ENV build_path="/opt/sources/build"
CMD [ "bash", "-c", "latexmk -synctex=1 -interaction=nonstopmode -file-line-error -pdf -Werror -outdir=$build_path $tex_file" ]
