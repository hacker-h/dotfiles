#!/bin/bash

# Set default download directory, override with $1 if provided
DOWNLOAD_DIR="${1:-${HOME}/software}"
mkdir -p "$DOWNLOAD_DIR"

FINAL_PATH="${DOWNLOAD_DIR}/pcloud"

echo "Installing pCloud..."

# Get the latest pCloud download URL
LATEST_PCLOUD_DOWNLOAD=$(curl -s https://api.pcloud.com/getlastversion?os=ELECTRON | jq -r '."linux-x64-prod".update')

if [ ! -f "$FINAL_PATH" ]; then
    wget "${LATEST_PCLOUD_DOWNLOAD}" -O "$FINAL_PATH" -q --show-progress
    chmod +x "$FINAL_PATH"
    echo "pCloud has been installed to $FINAL_PATH"
else
    echo "pCloud is already installed at $FINAL_PATH"
    echo "Checking for updates..."

    # Compare the installed version with the latest version
    INSTALLED_VERSION=$(cat "${HOME}/.local/share/applications/appimagekit_*-pcloud.desktop" | grep X-AppImage-Version | cut -d'=' -f2)
    LATEST_VERSION=$(curl -s https://api.pcloud.com/getlastversion?os=ELECTRON | jq -r '."linux-x64-prod".version')
    
    if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
        echo "Updating pCloud from ${INSTALLED_VERSION} to ${LATEST_VERSION}..."
        wget "${LATEST_PCLOUD_DOWNLOAD}" -O "$FINAL_PATH" -q --show-progress
        chmod +x "$FINAL_PATH"
        echo "pCloud has been updated to version ${LATEST_VERSION}"
    else
        echo "pCloud is already up to date (version ${INSTALLED_VERSION})"
    fi
fi

echo "pCloud installation complete."