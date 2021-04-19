#!/bin/bash

# docker
alias dprune="docker system prune -f && docker volume prune -f"

# git
git config --global core.autocrlf false
git config --global user.name "Henning Häcker"
git config --global user.email "henning.haecker+github.com@gmail.com"

# pip fast timeout
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

upgrade_dotfiles() {
    bash ~/src/github.com/hacker-h/dotfiles/install.bash
}

upgrade_terraform() {
    curl -O $(echo "https://releases.hashicorp.com/terraform/$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')/terraform_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')_linux_amd64.zip")
    unzip ./terraform_*.zip
    sudo mv ./terraform /usr/local/bin/terraform
    sudo chmod +x /usr/local/bin/terraform
    rm ./terraform_*.zip
    terraform version
}

reboot_to_windows() {
sudo grub-reboot 2 && sudo reboot
}

# vscode
alias scode="sudo code --user-data-dir ${HOME}"

# other
alias apt="sudo apt"
alias fix-audio="pulseaudio -k && sudo alsa force-reload"
alias l="ls"
alias ll="ls -lah"
alias refresh="source ~/.bashrc"

HISTTIMEFORMAT='%F %T '
HISTFILESIZE=-1
HISTSIZE=-1
HISTCONTROL=ignoredups
HISTIGNORE=?:??
shopt -s histappend                 # append to history, don't overwrite it
# attempt to save all lines of a multiple-line command in the same history entry
shopt -s cmdhist
# save multi-line commands to the history with embedded newlines
shopt -s lithist
# run history -a at each shell prompt => save new lines immediately to history
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
