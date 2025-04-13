#!/bin/bash
set -eu

# Default version to install
TOFU_VERSION="${1:-latest}"

echo "Installing OpenTofu..."

# Install prerequisites
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

# Create keyrings directory
sudo install -m 0755 -d /etc/apt/keyrings

# Download and install GPG keys
curl -fsSL https://get.opentofu.org/opentofu.gpg | sudo tee /etc/apt/keyrings/opentofu.gpg >/dev/null
curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | sudo gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg >/dev/null
sudo chmod a+r /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg

# Add repository
echo "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main
deb-src [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | sudo tee /etc/apt/sources.list.d/opentofu.list > /dev/null
sudo chmod a+r /etc/apt/sources.list.d/opentofu.list

# Update and install
sudo apt-get update

if [ "$TOFU_VERSION" = "latest" ]; then
    sudo apt-get install -y tofu
else
    sudo apt-get install -y tofu=$TOFU_VERSION
fi

# Verify installation
if command -v tofu >/dev/null 2>&1; then
    echo "OpenTofu installed successfully:"
    tofu --version
else
    echo "Failed to install OpenTofu"
    exit 1
fi 