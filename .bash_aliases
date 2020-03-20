#!/bin/bash

# docker
alias dprune="docker system prune -f && docker volume prune -f"

# git
git config --global core.autocrlf false
git config --global user.name "Henning Häcker"
git config --global user.email "henning.haecker+github.com@gmail.com"

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

upgrade_terraform() {
    curl -O $(echo "https://releases.hashicorp.com/terraform/$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')/terraform_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')_linux_amd64.zip")
    unzip ./terraform_*.zip
    sudo mv ./terraform /usr/local/bin/terraform
    sudo chmod +x /usr/local/bin/terraform
    rm ./terraform_*.zip
    terraform version
}

# podman
which docker > /dev/null || alias docker="podman"

# vscode
alias scode="sudo code --user-data-dir ${HOME}"

# other
alias apt="sudo apt"
alias fix-audio="pulseaudio -k && sudo alsa force-reload"
alias refresh="source ~/.bashrc"
