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

# pip
pip3() {
    if [[ $@ == "install"* ]]; then
        command pip3 --default-timeout=0.3 "$@"
    else
        command pip3 "$@"
    fi
}
pip() {
    if [[ $@ == "install"* ]]; then
        command pip --default-timeout=0.3 "$@"
    else
        command pip "$@"
    fi
}

# other
alias apt="sudo apt"
alias refresh="source ~/.bashrc"
