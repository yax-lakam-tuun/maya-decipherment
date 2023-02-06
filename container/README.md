
Mention linux docker

# What does it do?


# How to use it
Let's assume we are in the root folder of our repository.
To build a docker container named `maya-hod`, one types:

    docker build -t maya-hod container/

To run the container, please enter the following line:

    docker run -v$(pwd)/:/opt/sources maya-hod

# Usage in VSCode
The container is also used to create so-called "devcontainer"