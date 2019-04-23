#!/bin/bash

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
    # TODO
    docker() {
        if [[ $@ == "create"* ]] || [[ $@ == "run"* ]]; then
        command docker $(echo "$@" | sed 's~-v /~-v //~g' | sed 's~:/~://~g')
        else
            command docker "$@"
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
