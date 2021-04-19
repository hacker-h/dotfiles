set -eu

export DEBIAN_FRONTEND=noninteractive

# disable root password prompt
echo "${USER} ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo

sudo apt-get remove update-notifier -y

sudo apt-get install --reinstall ca-certificates tzdata

# configure time zone
sudo ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime
sudo dpkg-reconfigure --frontend noninteractive tzdata

# create some directories
mkdir -p ~/software ~/nextcloudLocal ~/nextcloudCryptomator ~/cryptomator ~/.keys

# add apt repositories
# keepassxc
sudo add-apt-repository -y ppa:phoerious/keepassxc
# cryptomator
sudo add-apt-repository -y ppa:sebastian-stenzel/cryptomator
# vscodium
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/etc/apt/trusted.gpg.d/vscodium.gpg
echo 'deb https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs/ vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
# signal
curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal-xenial.list

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y apt-file \
			bmon \
                        codium \
                        cryptomator \
                        curl \
			filezilla \
                        git \
                        htop \
                        iotop \
                        jq \
                        keepassxc \
                        net-tools \
                        nextcloud-desktop \
                        nmap \
                        ntfs-3g \
                        python3-pip \
                        signal-desktop \
                        snap \
                        strace \
                        terminator \
                        torbrowser-launcher \
                        vlc \
                        vim \
                        virtualenv \
                        xdotool
# pip upgrade
sudo pip3 install pip --upgrade

# google chrome
cd /tmp
ls google-chrome-stable_current_amd64.deb || wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb

# pcloud
#https://www.pcloud.com/how-to-install-pcloud-drive-linux.html?download=electron-64
LATEST_PCLOUD_DOWNLOAD=$(curl https://api.pcloud.com/getlastversion?os=ELECTRON | jq -r '."linux-x64-prod".update')
wget ${LATEST_PCLOUD_DOWNLOAD}
sudo chmod +x ./pcloud
sudo mv ./pcloud ~/software/

# chromium
sudo snap install chromium

# docker
curl -fsSL https://get.docker.com | sh -
sudo usermod -aG docker ${USER}

# docker-compose
export CRYPTOGRAPHY_DONT_BUILD_RUST=1
sudo pip3 install docker-compose
# if this fails => install cargo
#sudo apt-get install build-essential libssl-dev libffi-dev python3-dev cargo
#sudo pip3 install docker-compose
# if this also fails => install rust:
#curl https://sh.rustup.rs -sSf | sh -s -- -y
#sudo pip3 install docker-compose

# Ultimaker Cura
LATEST_CURA_VERSION=$(curl https://github.com/Ultimaker/Cura/tags | grep /Ultimaker/Cura/releases/tag/[1-9]\. | cut -d'"' -f4 | cut -d'/' -f6 | grep -v beta | sort -u | tail -n1)
cd ~/software
ls Ultimaker_Cura-${LATEST_CURA_VERSION}.AppImage || wget https://storage.googleapis.com/software.ultimaker.com/cura/Ultimaker_Cura-${LATEST_CURA_VERSION}.AppImage
chmod +x ~/software/Ultimaker_Cura-${LATEST_CURA_VERSION}.AppImage

# Cura Octoprint plugin
SHORT_CURA_VERSION=$(echo ${LATEST_CURA_VERSION} | cut -d'.' -f1-2)
mkdir -p ~/.local/share/cura/${SHORT_CURA_VERSION}/plugins
cd ~/.local/share/cura/${SHORT_CURA_VERSION}/plugins
git clone https://github.com/fieldOfView/Cura-OctoPrintPlugin ./OctoPrintPlugin || cd ./OctoPrintPlugin && git pull origin master

# fetch dotfiles
curl https://raw.githubusercontent.com/hacker-h/dotfiles/master/install.bash | sh -
source ~/.bash_aliases

# keepassxc config
mkdir -p ~/.config/keepassxc
ln -s ~/src/github.com/hacker-h/dotfiles/keepassxc.ini ~/.config/keepassxc/keepassxc.ini
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
ln -s ~/src/github.com/hacker-h/dotfiles/terminator.config ~/.config/terminator/config
# vscodium config
mkdir -p ~/.config/VSCodium/User
ln -s ~/src/github.com/hacker-h/dotfiles/vscodium.json ~/.config/VSCodium/User/settings.json
# reload pulseaudio
fix-audio

# autorun for nextcloud with 3s delay (workaround until release of https://github.com/ubuntu/gnome-shell-extension-appindicator/pull/260)
# cat ${HOME}/.config/autostart/custom_nextcloud.desktop 2>&1 | grep X-GNOME-Autostart-Delay || \
cat > ${HOME}/.config/autostart/custom_nextcloud.desktop << EOF
[Desktop Entry]
Name=Nextcloud
GenericName=File Synchronizer
Exec=/usr/bin/nextcloud
Terminal=false
Icon=nextcloud
Categories=Network
Type=Application
StartupNotify=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=5
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

systemctl restart systemd-logind
# manual steps

# firefox -> firefox account -> login
# => email code verification
# trigger firefox sync

# load ssh config from keepassxc => Desktop
# mv ~/Desktop/config ~/.ssh/config

# firefox:
# enable menu bar
# enable bookmarks toolbar
# customize => remove clutter from ui
# remove clutter from address bar in normal mode
# Firefox Preferences -> Privacy & Security -> Uncheck:
# -> Allow Firefox to send technical and interaction data to Mozilla
# -> Allow Firefox to install and run studies
# Youtube -> TLS Lock -> Autoplay -> Allow Audio and Video
# Netflix -> TLS Lock -> Autoplay -> Allow Audio and Video
# Github -> Login with keepassxc integration
# 2FA Code eingeben

# launch Tor Browser => Download starts => installing
# -> Connect
# Tor Browser -> Preferences -> Tabs -> Ctrl+Tab cycles through tabs in recently used order

# uMatrix -> Go to the dashboard -> Settings -> Enable cloud storage support
# uMatrix -> My rules -> cloudPullAndMerge -> Commit
# uBlock -> Open the dashboard -> Settings -> Enable cloud storage support
# uBlock -> for each tab: cloudPullAndMerge -> Commit

# generate + save ssh keys in ~/.keys

# Run nextcloud desktop sync client => login
# restart nextcloud desktop sync client

# add pcloud sync: nextcloudLocal => pCloudRemote
