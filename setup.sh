#!/bin/bash
# Ubuntu 24.04 LTS setup script
# This script automates the installation and configuration of a new Ubuntu 24.04 system
#
# Changes for Ubuntu 24.04:
# - Removed Python 3.8/3.9 installations (Ubuntu 24.04 comes with Python 3.12 by default)
# - Updated all repository keys to use modern /etc/apt/keyrings/ format (apt-key is deprecated)
# - Changed pip installations to use --user flag (best practice, no sudo needed)
# - Removed obsolete virtualenv package (use python3 -m venv instead)
# - KeePassXC PPA commented out (available in official repos, PPA only for latest version)

set -eu
shopt -s expand_aliases
export DEBIAN_FRONTEND=noninteractive

# disable root password prompt
echo "${USER} ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo

sudo apt-get remove update-notifier -y

# Note: apt-transport-https is obsolete since Ubuntu 17.10 (APT 1.5+)
# HTTPS support is built into apt by default in Ubuntu 24.04

sudo apt-get install -y --reinstall ca-certificates software-properties-common tzdata

# configure time zone
sudo ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime
sudo dpkg-reconfigure --frontend noninteractive tzdata

# fix time format compatibility with dual boot windows
timedatectl set-local-rtc 1

# create some directories
mkdir -p ~/software ~/nextcloudLocal ~/nextcloudCryptomator ~/cryptomator ~/.keys

# create keyrings directory for apt keys (modern way, apt-key is deprecated)
sudo mkdir -p /etc/apt/keyrings

# add apt repositories
# keepassxc - available in official Ubuntu 24.04 repos, PPA only needed for latest version
# sudo add-apt-repository -y ppa:phoerious/keepassxc

# cryptomator - PPA or AppImage
sudo add-apt-repository -y ppa:sebastian-stenzel/cryptomator

# vscodium - using modern signed-by format
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/etc/apt/keyrings/vscodium-archive-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/vscodium-archive-keyring.gpg] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs/ vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list

# signal - using modern signed-by format (xenial repo works on all Ubuntu versions)
wget -qO - https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor | sudo dd of=/etc/apt/keyrings/signal-desktop-keyring.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal-xenial.list

# element - already using modern format
sudo wget -O /etc/apt/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | sudo tee /etc/apt/sources.list.d/element-io.list

# avidemux
sudo add-apt-repository -y ppa:xtradeb/apps

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get remove ubuntu-advantage-tools -y
sudo apt-get install -y apt-file \
                        avidemux-qt \
                        avidemux-jobs-qt \
                        bmon \
                        build-essential \
                        codium \
                        cryptomator \
                        curl \
                        element-desktop \
                        filezilla \
                        git \
                        git-crypt \
                        htop \
                        inotify-tools \
                        iotop \
                        jq \
                        keepassxc \
                        net-tools \
                        nmap \
                        ntfs-3g \
                        pdfarranger \
                        python3 \
                        python3-pip \
                        python3-dev \
                        python3-venv \
                        signal-desktop \
                        snapd \
                        sshfs \
                        strace \
                        terminator \
                        torbrowser-launcher \
                        vagrant \
                        vim \
                        virtualbox \
                        vlc \
                        whois \
                        xdotool

# fetch dotfiles
curl https://raw.githubusercontent.com/hacker-h/dotfiles/master/install.bash | sh -

source ~/.bash_aliases

# Note: Ubuntu 24.04 comes with Python 3.12 by default, no need for older versions
# pip is already installed via python3-pip package above
# To create virtual environments, use: python3 -m venv myenv

# upgrade pip to latest version
python3 -m pip install --user --upgrade pip

# install pip dependencies for torbrowser launcher
python3 -m pip install --user requests

# install platformio CLI
python3 -m pip install --user -U platformio

# install speedtest cli
python3 -m pip install --user speedtest-cli

# google chrome
cd /tmp
ls google-chrome-stable_current_amd64.deb || wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

# pcloud
#https://www.pcloud.com/how-to-install-pcloud-drive-linux.html?download=electron-64
LATEST_PCLOUD_DOWNLOAD=$(curl https://api.pcloud.com/getlastversion?os=ELECTRON | jq -r '."linux-x64-prod".update')
ls ~/software/pcloud || wget ${LATEST_PCLOUD_DOWNLOAD} -O ~/software/pcloud
sudo chmod +x ~/software/pcloud

# docker
curl -fsSL https://get.docker.com | sh -
sudo usermod -aG docker ${USER}

# AWS CLI
./install_aws_cli.sh

upgrade_nextcloud_desktop

# Golang dev environment
curl -LO https://get.golang.org/$(uname)/go_installer && chmod +x go_installer && ./go_installer && rm go_installer

# keepassxc config
mkdir -p ~/.config/keepassxc
ln -fs ~/src/github.com/hacker-h/dotfiles/keepassxc.ini ~/.config/keepassxc/keepassxc.ini
mkdir -p ~/.cache/keepassxc
cat << EOF | tee ~/.cache/keepassxc/keepassxc.ini
[General]
LastActiveDatabase=${HOME}/nextcloudLocal/keepassxc/db.kdbx
LastAttachmentDir=${HOME}/Desktop
LastChallengeResponse=@Variant(\0\0\0\x1c\0\0\0\0)
LastDatabases=${HOME}/nextcloudLocal/keepassxc/db.kdbx
LastDir=${HOME}/nextcloudLocal/keepassxc
LastKeyFiles=@Variant(\0\0\0\x1c\0\0\0\0)
LastOpenedDatabases=${HOME}/nextcloudLocal/keepassxc/db.kdbx

[Browser]
CustomBrowserLocation=
CustomBrowserType=2
EOF

# terminator config
mkdir -p ~/.config/terminator
ln -fs ~/src/github.com/hacker-h/dotfiles/terminator.config ~/.config/terminator/config
# vscodium config
mkdir -p ~/.config/VSCodium/User
ln -fs ~/src/github.com/hacker-h/dotfiles/vscodium.json ~/.config/VSCodium/User/settings.json

# autorun for nextcloud with 3s delay (workaround until release of https://github.com/ubuntu/gnome-shell-extension-appindicator/pull/260)
# cat ${HOME}/.config/autostart/custom_nextcloud.desktop 2>&1 | grep X-GNOME-Autostart-Delay || \
mkdir -p ${HOME}/.config/autostart
cat << EOF | tee ${HOME}/.config/autostart/custom_nextcloud.desktop
[Desktop Entry]
Name=Nextcloud
GenericName=File Synchronizer
Exec=/home/hacker/software/nextcloud-latest
Terminal=false
Icon=nextcloud
Categories=Network
Type=Application
StartupNotify=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=15
EOF

# nextcloud sync configs
mkdir -p ${HOME}/.config/Nextcloud
cat << EOF | tee ${HOME}/.config/Nextcloud/nextcloud.cfg
[General]
optionalServerNotifications=true

[Accounts]
0\Folders\1\ignoreHiddenFiles=false
0\Folders\1\localPath=${HOME}/nextcloudCryptomator/
0\Folders\1\paused=false
0\Folders\1\targetPath=/nextcloudCryptomator
0\Folders\2\ignoreHiddenFiles=false
0\Folders\2\localPath=${HOME}/nextcloudLocal/
0\Folders\2\paused=false
0\Folders\2\targetPath=/nextcloudRemote
EOF

# nextcloud Desktop icon
cat << EOF | tee ${HOME}/.local/share/applications/nextcloud-latest.desktop
[Desktop Entry]
Categories=Utility;X-SuSE-SyncUtility;
Type=Application
Exec=/home/hacker/software/nextcloud-latest
Name=Nextcloud desktop sync client 
Comment=Nextcloud desktop synchronization client
GenericName=Folder Sync
Icon=Nextcloud
Keywords=Nextcloud;syncing;file;sharing;
X-GNOME-Autostart-Delay=3
EOF

# fix monitor order on login screen
sudo cp ~/.config/monitors.xml ~gdm/.config/monitors.xml
sudo cp ~/.config/monitors.xml ~/.config/monitors.xml~
sudo chown gdm:gdm ~gdm/.config/monitors.xml

# disables suspend/hibernate, thanks @ https://serverfault.com/a/1045950
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
cat <<"EOF" | sudo tee /etc/systemd/logind.conf
# This file is part of systemd.
# See logind.conf(5) for details.

[Login]
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF

# cryptomator
mkdir -p ${HOME}/.config/Cryptomator
cat << EOF | tee ${HOME}/.config/Cryptomator/settings.json
{
  "directories": [
    {
      "id": "YSFsle1Cy_Te",
      "path": "${HOME}/nextcloudCryptomator",
      "displayName": "nextcloudCryptomator",
      "unlockAfterStartup": true,
      "revealAfterMount": true,
      "useCustomMountPath": false,
      "usesReadOnlyMode": false,
      "mountFlags": "",
      "filenameLengthLimit": 220,
      "actionAfterUnlock": "REVEAL"
    }
  ],
  "askedForUpdateCheck": false,
  "checkForUpdatesEnabled": false,
  "startHidden": false,
  "port": 42427,
  "numTrayNotifications": 3,
  "preferredGvfsScheme": "DAV",
  "debugMode": false,
  "preferredVolumeImpl": "FUSE",
  "theme": "LIGHT",
  "uiOrientation": "LEFT_TO_RIGHT",
  "keychainBackend": "GNOME",
  "licenseKey": "",
  "showMinimizeButton": false,
  "showTrayIcon": false
}
EOF

sudo apt-file update

# (re-) install suitable gpu driver
sudo ubuntu-drivers autoinstall

# grant USB device permissions
sudo usermod -a -G dialout ${USER}
newgrp dialout

# ==============================================================================
# MANUAL STEPS - Complete these after the script finishes
# ==============================================================================

echo ""
echo "=========================================================================="
echo "Script completed! Please complete the following manual steps:"
echo "=========================================================================="
echo ""
echo "1. SSH CONFIGURATION"
echo "   - Load ssh config from KeePassXC to Desktop"
echo "   - Run: mv ~/Desktop/config ~/.ssh/config"
echo "   - Generate and save SSH keys in ~/.keys/"
echo "   - Set proper permissions: chmod 600 ~/.ssh/config ~/.keys/*"
echo ""
echo "2. FIREFOX SETUP"
echo "   - Login to Firefox Account (requires email verification)"
echo "   - Trigger Firefox sync to restore bookmarks and extensions"
echo "   - Enable menu bar and bookmarks toolbar"
echo "   - Customize toolbar: remove clutter from UI and address bar"
echo "   - Privacy & Security settings:"
echo "     * Uncheck 'Allow Firefox to send technical and interaction data to Mozilla'"
echo "     * Uncheck 'Allow Firefox to install and run studies'"
echo "   - about:config -> search 'webgpu' -> enable"
echo "   - Site permissions (TLS Lock icon):"
echo "     * YouTube: Autoplay -> Allow Audio and Video"
echo "     * Netflix: Autoplay -> Allow Audio and Video"
echo ""
echo "3. KEEPASSXC SETUP"
echo "   - Open KeePassXC database from ~/nextcloudLocal/keepassxc/db.kdbx"
echo "   - Tools -> Settings -> Browser Integration -> check 'Firefox' -> OK"
echo "   - Install KeePassXC browser extension in Firefox"
echo "   - KeePassXC Addon -> Connected Databases -> Connect"
echo "   - KeePassXC Addon Settings -> check 'Automatically reconnect to KeePassXC'"
echo "   - Test login on GitHub using KeePassXC integration (2FA required)"
echo ""
echo "4. TOR BROWSER SETUP"
echo "   - Launch Tor Browser (will download and install on first run)"
echo "   - Click 'Connect' to establish Tor connection"
echo "   - Preferences -> Tabs -> Enable 'Ctrl+Tab cycles through tabs in recently used order'"
echo ""
echo "5. BROWSER EXTENSIONS (via Firefox Sync)"
echo "   - uMatrix: Dashboard -> Settings -> Enable cloud storage support"
echo "   - uMatrix: My rules -> cloudPullAndMerge -> Commit"
echo "   - uBlock Origin: Dashboard -> Settings -> Enable cloud storage support"
echo "   - uBlock Origin: For each tab -> cloudPullAndMerge -> Commit"
echo ""
echo "6. NEXTCLOUD DESKTOP SETUP"
echo "   - Run Nextcloud desktop sync client from ~/software/nextcloud-latest"
echo "   - Login to Nextcloud account"
echo "   - Restart Nextcloud client after initial sync"
echo "   - Settings -> General -> Verify 'Launch on System Startup' is checked"
echo "   - Verify sync folders are configured correctly (see ~/.config/Nextcloud/nextcloud.cfg)"
echo ""
echo "7. PCLOUD SETUP"
echo "   - Launch pCloud from ~/software/pcloud"
echo "   - Login and configure sync"
echo "   - Add sync mapping: nextcloudLocal -> pCloudRemote"
echo ""
echo "8. CRYPTOMATOR"
echo "   - Cryptomator should auto-unlock vault at ~/nextcloudCryptomator on startup"
echo "   - Verify configuration in ~/.config/Cryptomator/settings.json"
echo ""
echo "9. REBOOT REQUIRED"
echo "   - System reboot recommended to apply all changes"
echo "   - Verify docker group membership with: groups"
echo "   - Verify GPU driver installation after reboot"
echo ""
echo "=========================================================================="
