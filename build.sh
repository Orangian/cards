#!/bin/bash
export PROFILE=~/cards-profile
set +h
umask 0022 # Correct file permissions

pacman -Syu archiso --noconfirm
cp -r /usr/share/archiso/configs/baseline/ ${PROFILE}
cp -rf ./cards/. ${PROFILE}

tee -a ${PROFILE}/packages.x86_64 > /dev/null <<EOT
arch-install-scripts
ethtool
exfatprogs
f2fs-tools
fsarchiver
gnu-netcat
sudo
nano
nfs-utils
linux-atm
linux-firmware
lsscsi
reiserfsprogs
efibootmgr
dhcpd
btrfs-progs
broadcom-wl
bind-tools
b43-fwcutter
util-linux
xfsprogs
zsh
rsync

lightdm
mkinitcpio
mkinitcpio-archiso
EOT

echo -e "packages.x86_64:\n---"
echo "$(<${PROFILE}/packages.x86_64)"
echo "---"

rm -f ${PROFILE}/airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf
ln -s /lib/systemd/system/lightdm.service ${PROFILE}/airootfs/etc/systemd/system/display-manager.service

mkdir ./out
mkdir /tmp/archiso-tmp
mkarchiso -v -w /tmp/archiso-tmp ${PROFILE}
rm -rf /tmp/archiso-tmp
mv ./out/cards-*.*.*-x86_64.iso ~
