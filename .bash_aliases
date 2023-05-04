#!/bin/bash

# docker
alias dprune="docker system prune -f && docker volume prune -f"

# git
git config --global core.autocrlf false
git config --global core.editor "vim"
git config --global user.name "Henning Häcker"
git config --global user.email "henning.haecker+github.com@protonmail.com"

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

github_get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}
upgrade_terraform() {
    curl -O $(echo "https://releases.hashicorp.com/terraform/$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')/terraform_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')_linux_amd64.zip")
    unzip ./terraform_*.zip
    sudo mv ./terraform /usr/local/bin/terraform
    sudo chmod +x /usr/local/bin/terraform
    rm ./terraform_*.zip
    terraform version
}


upgrade_cura() {
    # Ultimaker Cura
    LATEST_CURA_RELEASE=$(github_get_latest_release Ultimaker/Cura)
    LATEST_CURA_VERSION=${LATEST_CURA_RELEASE}
    cd ~/software
    if find Ultimaker_Cura-${LATEST_CURA_VERSION}.AppImage; then
        echo "Ultimaker Cura is already up to date."
    else
        OLD_ULTIMAKER_BINARY=$(ls ${HOME}/software/Ultimaker*.AppImage)
        RELEASE_INFO=$(curl -s https://github.com/Ultimaker/Cura/releases/tag/${LATEST_CURA_RELEASE})
        LATEST_CURA_NAME=$(echo "${RELEASE_INFO}" | grep -Eo Ultimaker.*.AppImage\< | grep -Eo Ultimaker.*.AppImage)
        LATEST_CURA_LINK="https://github.com/Ultimaker/Cura/releases/download/${LATEST_CURA_RELEASE}/${LATEST_CURA_NAME}"
        wget "${LATEST_CURA_LINK}" -O ./Ultimaker_Cura-${LATEST_CURA_VERSION}.AppImage
        chmod +x ~/software/Ultimaker_Cura-${LATEST_CURA_VERSION}.AppImage
        if [ ! -z "${OLD_ULTIMAKER_BINARY}" ]; then
            rm "${OLD_ULTIMAKER_BINARY}"
        fi
    fi
}

upgrade_nextcloud_desktop() {
    # Nextcloud Desktop
    LATEST_NEXTCLOUD_RELEASE=$(github_get_latest_release nextcloud/desktop)
    LATEST_NEXTCLOUD_VERSION=$(echo ${LATEST_NEXTCLOUD_RELEASE} | cut -d'v' -f2-)
    cd ~/software
    if find Nextcloud-${LATEST_NEXTCLOUD_VERSION}-x86_64.AppImage; then
        echo "Nextcloud Desktop is already up to date."
    else
        OLD_NEXTCLOUD_BINARY=$(ls ${HOME}/software/Nextcloud*.AppImage)
        LATEST_NEXTCLOUD_LINK="https://github.com/nextcloud/desktop/releases/download/v${LATEST_NEXTCLOUD_VERSION}/Nextcloud-${LATEST_NEXTCLOUD_VERSION}-x86_64.AppImage"
        wget "${LATEST_NEXTCLOUD_LINK}" -O ./Nextcloud-${LATEST_NEXTCLOUD_VERSION}-x86_64.AppImage
        chmod +x ~/software/Nextcloud-${LATEST_NEXTCLOUD_VERSION}-x86_64.AppImage
        if [ ! -z "${OLD_NEXTCLOUD_BINARY}" ]; then
            rm "${OLD_NEXTCLOUD_BINARY}"
        fi
    fi
    ln -sf ~/software/Nextcloud-${LATEST_NEXTCLOUD_VERSION}-x86_64.AppImage ~/software/nextcloud-latest

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
PROMPT_COMMAND="history -a;${PROMPT_COMMAND:-}"

# android platform tools
export PATH="${HOME}/software/platform-tools:$PATH"
export PATH="${HOME}/.go/bin:$PATH"

# show git branch in bash prompt + * if there is diff to HEAD
parse_git_branch() {
    local branch=$(git symbolic-ref --short HEAD 2> /dev/null)
    if [ -n "$branch" ]; then
        echo " ($branch$(git status --porcelain | grep -q . && echo " *"))"
    fi
}

GREEN="\[\033[0;32m\]"
BLUE="\[\033[0;34m\]"
RESET="\[\033[0m\]"

PS1="\[$GREEN\]\u@\h:\[$BLUE\]\w\$(parse_git_branch)\[$RESET\]\$ "

