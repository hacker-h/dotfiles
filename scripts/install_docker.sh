#!/bin/bash

curl -fsSL https://get.docker.com | sh -

if [ $? -eq 0 ]; then
    sudo usermod -aG docker ${USER}
    echo "Docker has been installed successfully. Please log out and back in for the group changes to take effect."
else
    echo "There was an error installing Docker."
fi
