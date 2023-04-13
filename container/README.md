
# What does it do?
A Docker container is a virtual encapsulated environment.
The so-called host which is usually the computer, note-book or similar, creates and runs the Docker 
containers.
Unlike the host system, everything which can be installed and executed remains in the container and 
cannot alter the configuration of the host in any way.

The container used in this project contains everything needed to compile a LaTeX project.
It includes a complete TeX Live installation and several tools such as Git or Inkscape.
When the container is executed, it tries to compile the LaTeX project in a well-defined folder.
The output is a PDF file of the project.
See more in the section about 'How to use it'.

For more information about Docker in general, please refer to the official 
[documentation](https://docs.docker.com/).

# Docker installation
Docker is supported for Windows, macOS and Linux.
To install Docker, please see the 
[installation instructions](https://docs.docker.com/engine/install/) for further information.
Docker Desktop is usually quite easy to install as it comes with a GUI and easy to 
use installation wizard.

Note: Please make sure Docker Desktop is running before you start building or 
executing Docker containers.

# How to use it
Using a Docker container usually consists of two steps.
* Creating the container from a so-called recipe (aka `Dockerfile`)
* Container execution (similar to launching an application or script)

Upon creation, Docker assigns every container a tag - a unique name which can be anything 
human-readable.
This tag is unique and cannot be used by more than one container.
Despite the isolated character of containers, Docker containers can interact with the host 
by a network connection or by mounted volumes.

## Creating the container
Let's assume we are in the root folder of our repository.
To build a Docker container tagged `maya-hod`, one types:

    docker build -t maya-hod container/

## Executing the container
To run the container, please enter the following line:

    docker run -v$(pwd)/:/opt/sources maya-hod

In this project, a volume is used to map all files, documents, images etc. into the container.
The container works directly with the files on the host.
That means, once the git project is cloned locally, the Docker container can interact with the 
checked out folder structure and run LaTeX completely independent from the host.
Everything outside the specified folder (aka volume) cannot be touched (or even be seen) though.

# Usage in continuous integration
The container is used to power the GitHub workflows.
Those workflows are used to run the continuous integration pipelines and the release pipeline.
In both cases the pipeline produces a PDF file which is used to determine the state of the project 
and to create a (draft) release for the end-user.
See [Continuous Integration](../documentation/continuous-integration.md) for more information.

# Usage in VSCode
VSCode is able to run a virtual environment session in a 
Docker container - a so-called Dev Container.
This project uses the very same container for this purpose.
The configuration and several enhancements like extensions are defined in 
[devcontainer.json](../.devcontainer/devcontainer.json).
See [VSCode](../documentation/vscode.md) for more information.

# Technical details
The Docker container is based on Ubuntu - a free Linux distribution.
The container uses the same architecture of the host.
For instance, if the host is an Apple Silicon M1 machine, the Docker container runs an 
Ubuntu ARM64 while x64 machines use Ubuntu AMD64.
Even though, one can specify this independently, using a non-native architecture requires
emulation which is usually quite slow and the experience rather unpleasant.

# Troubleshooting
Sometimes, it can happen that the container hangs or is broken for some unknown reason.
In that case, it can be useful to erase all Docker images and re-create it again.
Erasing all images can be done in a terminal like this:

    docker system prune -a --volumes

Then, the Docker container can be built and run again with the commands above 
(see section 'How to use it').