#!/bin/bash

# Set default download directory, override with $1 if provided
DOWNLOAD_DIR="${1:-~/software}"
TEMP_DIR=$(mktemp -d)
FINAL_PATH="${DOWNLOAD_DIR}/Bambu_Studio_linux_ubuntu.AppImage"

# Function to get the latest release from GitHub repository
github_get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub API
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

# Bambu Studio
LATEST_BAMBU_RELEASE=$(github_get_latest_release bambulab/BambuStudio)
LATEST_BAMBU_VERSION=${LATEST_BAMBU_RELEASE#"v"} # Remove any leading 'v' to match versions correctly

# Check if configuration exists to get current installed version
if [ -f ~/.config/BambuStudio/BambuStudio.conf ]; then
    CURRENT_VERSION=$(cat ~/.config/BambuStudio/BambuStudio.conf | jq '.app.version' -r)
    echo "Currently installed Bambu Studio version: $CURRENT_VERSION"
    # Compare the current version with the latest version
    
    if [ "$CURRENT_VERSION" = "$LATEST_BAMBU_VERSION" ]; then
        echo "Bambu Studio is already up to date."
        exit 0
    else
        echo "Upgrading Bambu Studio from ${CURRENT_VERSION} to ${LATEST_BAMBU_VERSION} .."
        ail-cli unintegrate ${FINAL_PATH} &> /dev/null
    fi
else
    echo "Installing Bambu Studio ${LATEST_BAMBU_VERSION} .."
fi

# Prepare the download URL
LATEST_BAMBU_LINK="https://github.com/bambulab/BambuStudio/releases/download/v${LATEST_BAMBU_VERSION}/Bambu_Studio_linux_ubuntu-v${LATEST_BAMBU_VERSION}.AppImage"

# Download to temp directory first
TEMP_DOWNLOAD_PATH="${TEMP_DIR}/Bambu_Studio_linux_ubuntu-v${LATEST_BAMBU_VERSION}.AppImage"
echo "Downloading Bambu Studio to temporary directory..."
wget "${LATEST_BAMBU_LINK}" -O "${TEMP_DOWNLOAD_PATH}" -q --show-progress

chmod +x "${TEMP_DOWNLOAD_PATH}"
# Move from temp to the final directory
sudo mv "${TEMP_DOWNLOAD_PATH}" "${FINAL_PATH}"
ail-cli integrate ${FINAL_PATH} &> /dev/null

echo "Bambu Studio is now up to date"
