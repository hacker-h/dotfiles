#!/bin/bash

set -e

if GO_VERSION=$(go version); then
    echo "Go is already installed: ${GO_VERSION}"
else
    # Add the Go PPA
    sudo add-apt-repository -y ppa:longsleep/golang-backports

    # Install the latest version of Go
    sudo apt install -y golang-go

    # Verify installation
    if go version; then
        echo "Go has been successfully installed."
        
        # Set up GOPATH
        echo "export GOPATH=$HOME/go" >> $HOME/.profile
        echo "export PATH=\$PATH:\$GOPATH/bin" >> $HOME/.profile
        
        echo "GOPATH has been set to $HOME/go"
        echo "Please run 'source $HOME/.profile' or log out and back in to update your environment."
    else
        echo "There was an error installing Go."
        exit 1
    fi
fi
