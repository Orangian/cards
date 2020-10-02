#!/bin/bash
export PROFILE=~/cards-profile
set +h
umask 0022 # Correct file permissions

pacman -Syu archiso --noconfirm
cp -r /usr/share/archiso/configs/releng/ ${PROFILE}
rm ${PROFILE}/packages.x86_64
cp -rf ./cards/. ${PROFILE}

tee -a ${PROFILE}/packages.x86_64 > /dev/null <<EOT
xorg
xorg-drivers
xorg-server
xorg-xinit
xf86-input-libinput
xterm
lightdm
mesa
gtk-engine-murrine
gtkspell3
qt5-svg
qt5-wayland
qt5-translations
vala
pantheon
lightdm-pantheon-greeter
switchboard-plug-desktop
switchboard-plug-locale
switchboard-plug-security-privacy
gnome-disk-utility
virtualbox-guest-utils
amd-ucode
arch-install-scripts
b43-fwcutter
base
bind-tools
broadcom-wl
btrfs-progs
clonezilla
crda
darkhttpd
ddrescue
dhclient
dhcpcd
diffutils
dmraid
dnsmasq
dosfstools
edk2-shell
efibootmgr
ethtool
exfatprogs
f2fs-tools
fsarchiver
gnu-netcat
gpm
gptfdisk
grml-zsh-config
haveged
hdparm
intel-ucode
ipw2100-fw
ipw2200-fw
irssi
iwd
jfsutils
kitty-terminfo
lftp
linux
linux-atm
linux-firmware
lsscsi
lvm2
lynx
man-db
man-pages
mc
mdadm
memtest86+
mkinitcpio
mkinitcpio-archiso
mkinitcpio-nfs-utils
mtools
nano
nbd
ndisc6
nfs-utils
nilfs-utils
nmap
ntfs-3g
nvme-cli
openconnect
openssh
openvpn
partclone
parted
partimage
ppp
pptpclient
reflector
reiserfsprogs
rp-pppoe
rsync
rxvt-unicode-terminfo
sdparm
sg3_utils
smartmontools
sudo
syslinux
systemd-resolvconf
tcpdump
terminus-font
termite-terminfo
testdisk
usb_modeswitch
usbutils
vim
vpnc
wireless-regdb
wireless_tools
wpa_supplicant
wvdial
xfsprogs
xl2tpd
zsh
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
