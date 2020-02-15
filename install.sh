#!/bin/sh
set -eu
cd ~/src/github.com/hacker-h/dotfiles && git pull origin master || git clone git@github.com:hacker-h/dotfiles.git ~/src/github.com/hacker-h/dotfiles
find ~/.bash_aliases && mv ~/.bash_aliases ~/.bash_aliases.old
ln -s ~/src/github.com/hacker-h/dotfiles/.bash_aliases ~/.bash_aliases
source ~/.bashrc
echo "Your dotfiles are now up to date!"
