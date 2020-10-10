#!/bin/bash
export HOME=~
export PROFILE=${HOME}/cards-profile
export LOCAL_REPO=${HOME}/local-repo
export ROOT=/__w/cards/cards
set +h
umask 0022 # Correct file permissions
systemd-machine-id-setup # Prevents errors when building AUR packages

# Begin setting up our profile
cp -r /usr/share/archiso/configs/releng/ ${PROFILE}
cp -rf ./cards/. ${PROFILE}
mkdir ${LOCAL_REPO}
repo-add ${LOCAL_REPO}/custom.db.tar.xz
chmod -R 777 ${LOCAL_REPO}
sed -i -e "s?~/local-repo?${LOCAL_REPO}?" ${PROFILE}/pacman.conf

# Add packages to our local repository (shared between host and profile)
cp -f ${PROFILE}/pacman.conf /etc
mkdir //.cache && chmod 777 //.cache # Since we can't run 'aur sync' as sudo, we have to make the cache directory manually
#pacman -Rdd gsettings-desktop-schemas
whoami
shutdown now
pwd
sudo mkdir /go
chown -R nobody:nobody /go
sudo mkdir /go/pkg
sudo mkdir /go/pkg/mod
sudo mkdir /go/pkg/mod/cache
sudo mkdir /go/pkg/mod/cache/download
su -s /bin/sh nobody -c "aur sync -d custom --root ${LOCAL_REPO} --no-confirm --noview \
ly \
yay \
openbox-patched \
rofi-git \
rofi-calc \
oranchelo-icon-theme-git \
tela-icon-theme-git \
ttf-comfortaa \
nerd-fonts-complete \
rofi-menus-git \
ttf-iosevka \
ymuse-git \
"

echo -e "LOCAL_REPO:\n---"
ls ${LOCAL_REPO}
echo "---"
