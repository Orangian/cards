#!/bin/bash
export HOME=~
export PROFILE=${HOME}/cards-profile
export LOCAL_REPO=${HOME}/local-repo
export ROOT=/__w/cards/cards
set +h
umask 0022 # Correct file permissions
systemd-machine-id-setup # Prevents errors when building AUR packages

# Remove the default bloated RELENG
rm ${PROFILE}/packages.x86_64
# Add packages from Arch's repositories to our profile
cat ${ROOT}/purged-releng.list >> ${PROFILE}/packages.x86_64
# Add custom packages to our profile
cat ${ROOT}/user-packages.list >> ${PROFILE}/packages.x86_64
# Add AUR packages to our profile
cat ${ROOT}/aur-packages.list >> ${PROFILE}/packages.x86_64

rm -f ${PROFILE}/airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf # Remove autologin
