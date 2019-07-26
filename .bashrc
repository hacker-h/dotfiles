#!/bin/bash

# git
git config --global core.autocrlf true
git config --global user.name "Henning Häcker"
git config --global user.email "henning.haecker+github.com@gmail.com"

# terraform
alias tf="terraform"
alias ta="terraform apply"
alias td="terraform destroy"
alias to="terraform output"
terraform() {
    if [[ $@ == "apply"* ]] || [[ $@ == "destroy"* ]]; then
        command terraform $(echo "$@" | sed 's/-y/--auto-approve/g')
    else
        command terraform "$@"
    fi
}

# docker
if [[ "$OSTYPE" == "msys" ]]; then
    docker() {
        if [[ $@ == "create"* ]] || [[ $@ == "run"* ]]; then
        command winpty docker $(echo "$@" | sed 's~-v /~-v //~g' | sed 's~:/~://~g')
        else
            command winpty docker "$@"
        fi
    }
elif [[ "$OSTYPE" == "linux-gnu" ]] || [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]] || [[ "$OSTYPE" == "freebsd"* ]]; then
    echo "nothing to do"
else
    echo "unsupported os: '${OSTYPE}'"
fi

# other
alias ll="ls -la"
alias wget="curl -O"
