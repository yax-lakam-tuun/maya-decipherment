# What is VSCode?
VSCode is a source code editor and development tool.
It contains a project explorer where all the files and folders are displayed.
VSCode has a text editor with syntax highlighting, auto completion and spell checking.
In addition, it integrates terminals like Bash, ZSH or PowerShell and many more. 
to run commands, applications and scripts.
Please refer to VSCode's website for more information: https://code.visualstudio.com/

It is a useful tool to manage folder and file based structures.
With its capabilities to install extensions such as LaTeX, 
it is quite convenient to compile a PDF document while continuing writing texts.
Another adventage is its seamlessly integration of git.
This make it easy to author new files, alter existing ones etc. and 
afterwards commit and push them to the working branch.
The UI and an integrated file browser makes it easy to manage the changes being applied 
to the project.

## Dev Container
VSCode has the opportunity to be used in conjunction with docker containers 
(see [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)).
This makes it possible to run a standardized virtual environment in a docker container 
which enables the user to write and create PDF files from a given LaTeX file structure 
(see [docker chapter](../container/README.md)).
It's an easy and isolated way to create a LaTeX environment and everything a consumer or writer
needs in order to compile the final PDF file.
This project fully supports Dev Containers. 
The configuration can be found here [devcontainer.json](../.devcontainer/devcontainer.json). 
The same docker recipe (see [Dockerfile](../container/Dockerfile)) is also used during the 
continuous integration cycle (see [CI chapter](continuous-integration.md)).
