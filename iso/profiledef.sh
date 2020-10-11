#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="Laufen"
iso_label="LME_$(date +%Y%m)"
iso_publisher="Eile Kerning <http://www.github.com/orangian>"
iso_application="A lightweight Arch distro."
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
