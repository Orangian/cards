#!/bin/bash
export HOME=~
export PROFILE=${HOME}/cards-profile
export LOCAL_REPO=${HOME}/local-repo
set +h
umask 0022 # Correct file permissions
systemd-machine-id-setup # Prevents errors when building AUR packages

pacman -Syu archiso git base-devel jq expac diffstat pacutils wget devtools libxslt cmake \
intltool polkit dbus-glib light-locker --noconfirm --noprogressbar # Install packages we'll need to build

# Allow us to use a standard user account w/ password-less sudo privilege (for building AUR packages later)
tee -a /etc/sudoers > /dev/null <<EOT
nobody    ALL=(ALL) NOPASSWD:ALL
EOT

# Install aurutils to build our local repository from AUR packages
git clone https://aur.archlinux.org/aurutils.git
chmod 777 aurutils
cd aurutils
su -s /bin/sh nobody -c "makepkg -si --noconfirm --noprogressbar" # Make aurutils as a regular user
cd ../

# Begin setting up our profile
cp -r /usr/share/archiso/configs/releng/ ${PROFILE}
cp -rf ./cards/. ${PROFILE}
mkdir ${LOCAL_REPO}
repo-add ${LOCAL_REPO}/custom.db.tar.xz
chmod -R 777 ${LOCAL_REPO}
sed -i -e "s?~/local-repo?${LOCAL_REPO}?" ${PROFILE}/pacman.conf
rm ${PROFILE}/packages.x86_64

# Add packages to our local repository (shared between host and profile)
cp -f ${PROFILE}/pacman.conf /etc
mkdir //.cache && chmod 777 //.cache # Since we can't run 'aur sync' as sudo, we have to make the cache directory manually
su -s /bin/sh nobody -c "aur sync -d custom --root ${LOCAL_REPO} --no-confirm --noview \
yay \
lightdm-mini-greeter"

echo -e "LOCAL_REPO:\n---"
ls ${LOCAL_REPO}
echo "---"

# Add packages from Arch's repositories to our profile
tee -a ${PROFILE}/packages.x86_64 > /dev/null <<EOT
## Purged RELENG
amd-ucode
arch-install-scripts
b43-fwcutter
base
bind-tools
broadcom-wl
btrfs-progs
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
linux
linux-atm
linux-firmware
lsscsi
lvm2
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
ntfs-3g
nvme-cli
openconnect
openssh
partclone
parted
partimage
reflector
reiserfsprogs
rsync
rxvt-unicode-terminfo
sdparm
sg3_utils
smartmontools
sudo
syslinux
systemd-resolvconf
tcpdump
testdisk
usb_modeswitch
usbutils
wireless-regdb
wireless_tools
wpa_supplicant
wvdial
xfsprogs
zsh
go
## X11 and drivers
xorg
xorg-server
xorg-drivers
xorg-xinit
xorg-xclock
xorg-twm
xterm
xf86-input-libinput
mesa
libva
libva-mesa-driver
intel-ucode
intel-tbb

## Wayland
wayland
wayland-protocols
glfw-wayland
qt5-wayland
xorg-server-xwayland
wlc

## Display & Misc. Desktop Environment
lightdm
alacritty
i3-gaps
cups
cups-pk-helper
gvfs
gvfs-afc
gvfs-mtp
gvfs-nfs
gvfs-smb
alacritty

## VirtualBox
#virtualbox-guest-utils
## AUR
EOT

rm -f ${PROFILE}/airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf # Remove autologin

# Enable our daemons
mkdir -p ${PROFILE}/airootfs/etc/systemd/system/multi-user.target.wants
mkdir -p ${PROFILE}/airootfs/etc/systemd/system/sockets.target.wants
mkdir -p ${PROFILE}/airootfs/etc/systemd/system/bluetooth.target.wants
mkdir -p ${PROFILE}/airootfs/etc/modules-load.d
ln -s /lib/systemd/system/lightdm.service ${PROFILE}/airootfs/etc/systemd/system/display-manager.service
ln -s /lib/systemd/system/NetworkManager.service ${PROFILE}/airootfs/etc/systemd/system/multi-user.target.wants
ln -s /lib/systemd/system/cups.socket ${PROFILE}/airootfs/etc/systemd/system/sockets.target.wants
ln -s /lib/systemd/system/avahi-daemon.socket ${PROFILE}/airootfs/etc/systemd/system/sockets.target.wants
ln -s /lib/systemd/system/bluetooth.service ${PROFILE}/airootfs/etc/systemd/system/bluetooth.target.wants
#ln -s /lib/modules-load.d/virtualbox-guest-dkms.conf ${PROFILE}/airootfs/etc/modules-load.d


# Build & bundle the disk image
mkdir ./out
mkdir /tmp/archiso-tmp
mkarchiso -v -w /tmp/archiso-tmp ${PROFILE}
mv ./out/cards-*.*.*-x86_64.iso ~
