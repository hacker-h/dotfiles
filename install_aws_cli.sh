#!/bin/bash
set -e

echo "Installing AWS CLI..."

# Download AWS CLI
echo "Downloading AWS CLI..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip the package
echo "Extracting AWS CLI..."
unzip -q awscliv2.zip

# Install AWS CLI
echo "Installing AWS CLI..."
sudo ./aws/install

# Cleanup
echo "Cleaning up installation files..."
rm -rf awscliv2.zip aws

echo "AWS CLI installation completed successfully!" 