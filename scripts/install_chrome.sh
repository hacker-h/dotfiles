#!/bin/bash

TEMP_DIR="/tmp"
CHROME_DEB="google-chrome-stable_current_amd64.deb"

cd "$TEMP_DIR"

if [ ! -f "$CHROME_DEB" ]; then
    wget https://dl.google.com/linux/direct/"$CHROME_DEB"
fi

sudo dpkg -i "$CHROME_DEB"

if [ $? -eq 0 ]; then
    echo "Google Chrome has been successfully installed."
else
    echo "There was an error installing Google Chrome."
fi
