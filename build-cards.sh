set +h
umask 022
export LC_ALL=POSIX
export PATH=${CARDS}/cross-tools/bin:/bin:/usr/bin
unset CFLAGS
unset CXXFLAGS
export CARDS_HOST=$(echo ${MACHTYPE} | sed "s/-[^-]*/-cross/")
export CARDS_TARGET=x86_64-linux-gnu
export CARDS_CPU=k8
export CARDS_ARCH=$(echo ${CARDS_TARGET} | sed -e 's/-.*//' -e 's/i.86/i386/')
export CARDS_ENDIAN=little
export CC="${CARDS_TARGET}-gcc"
export CXX="${CARDS_TARGET}-g++"
export CPP="${CARDS_TARGET}-gcc -E"
export AR="${CARDS_TARGET}-ar"
export AS="${CARDS_TARGET}-as"
export LD="${CARDS_TARGET}-ld"
export RANLIB="${CARDS_TARGET}-ranlib"
export READELF="${CARDS_TARGET}-readelf"
export STRIP="${CARDS_TARGET}-strip"

# Create the filesystem hierarchy
mkdir -p ${CARDS}
mkdir -p ${CARDS}/{bin,boot{,grub},dev,{etc/,}opt,home,lib/{firmware,modules},lib64,mnt}
mkdir -p ${CARDS}/{proc,media/{floppy,cdrom},sbin,srv,sys}
mkdir -p ${CARDS}/var/{lock,log,mail,run,spool}
mkdir -p ${CARDS}/var/{opt,cache,lib/{misc,locate},local}
install -d -m 0750 ${CARDS}/root
install -d -m 1777 ${CARDS}{/var,}/tmp
install -d ${CARDS}/etc/init.d
mkdir -p ${CARDS}/usr/{,local/}{bin,include,lib{,64},sbin,src}
mkdir -p ${CARDS}/usr/{,local/}share/{doc,info,locale,man}
mkdir -p ${CARDS}/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -p ${CARDS}/usr/{,local/}share/man/man{1,2,3,4,5,6,7,8}
for dir in ${CARDS}/usr{,/local}; do
    ln -s share/{man,doc,info} ${dir}
done
mkdir -p ${CARDS}/boot/grub

install -d ${CARDS}/cross-tools{,/bin} # Create directory for cross-compilation toolchain
ln -sf ../proc/mounts ${CARDS}/etc/mtab # Maintain list of mounted filesystems

# Create root user account
cat > ${CARDS}/etc/passwd << "EOF"
root::0:0:root:/root:/bin/ash
EOF

# Create /etc/group
cat > ${CARDS}/etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:4:
daemon:x:6:
disk:x:8:
dialout:x:10:
video:x:12:
utmp:x:13:
usb:x:14:
EOF

# Create /etc/fstab
cat > ${CARDS}/etc/fstab << "EOF"
# file system  mount-point  type   options          dump  fsck
#                                                         order

rootfs          /               auto    defaults        1      1
proc            /proc           proc    defaults        0      0
sysfs           /sys            sysfs   defaults        0      0
devpts          /dev/pts        devpts  gid=4,mode=620  0      0
tmpfs           /dev/shm        tmpfs   defaults        0      0
EOF

# Create /etc/profile (for Almquist shell)
cat > ${CARDS}/etc/profile << "EOF"
export PATH=/bin:/usr/bin

if [ `id -u` -eq 0 ] ; then
        PATH=/bin:/sbin:/usr/bin:/usr/sbin
        unset HISTFILE
fi


# Set up some environment variables.
export USER=`id -un`
export LOGNAME=$USER
export HOSTNAME=`/bin/hostname`
export HISTSIZE=1000
export HISTFILESIZE=1000
export PAGER='/bin/more '
export EDITOR='/bin/vi'
EOF

echo "Cards" > ${CARDS}/etc/HOSTNAME # Create default PC hostname

# Create login prompt message
cat > ${CARDS}/etc/issue<< "EOF"
Cards
Kernel \r on an \m

\U logged in at \t on \d
EOF

# Define BusyBox init process
cat > ${CARDS}/etc/inittab<< "EOF"
::sysinit:/etc/rc.d/startup

tty1::respawn:/sbin/getty 38400 tty1
tty2::respawn:/sbin/getty 38400 tty2
tty3::respawn:/sbin/getty 38400 tty3
tty4::respawn:/sbin/getty 38400 tty4
tty5::respawn:/sbin/getty 38400 tty5
tty6::respawn:/sbin/getty 38400 tty6

::shutdown:/etc/rc.d/shutdown
::ctrlaltdel:/sbin/reboot
EOF

# Setup mdev for BusyBox
cat > ${CARDS}/etc/mdev.conf<< "EOF"
# Devices:
# Syntax: %s %d:%d %s
# devices user:group mode

# null does already exist; therefore ownership has to
# be changed with command
null    root:root 0666  @chmod 666 $MDEV
zero    root:root 0666
grsec   root:root 0660
full    root:root 0666

random  root:root 0666
urandom root:root 0444
hwrandom root:root 0660

# console does already exist; therefore ownership has to
# be changed with command
console root:tty 0600 @mkdir -pm 755 fd && cd fd && for x in 0 1 2 3 ; do ln -sf /proc/self/fd/$x $x; done

kmem    root:root 0640
mem     root:root 0640
port    root:root 0640
ptmx    root:tty 0666

# ram.*
ram([0-9]*)     root:disk 0660 >rd/%1
loop([0-9]+)    root:disk 0660 >loop/%1
sd[a-z].*       root:disk 0660 */lib/mdev/usbdisk_link
hd[a-z][0-9]*   root:disk 0660 */lib/mdev/ide_links

tty             root:tty 0666
tty[0-9]        root:root 0600
tty[0-9][0-9]   root:tty 0660
ttyO[0-9]*      root:tty 0660
pty.*           root:tty 0660
vcs[0-9]*       root:tty 0660
vcsa[0-9]*      root:tty 0660

ttyLTM[0-9]     root:dialout 0660 @ln -sf $MDEV modem
ttySHSF[0-9]    root:dialout 0660 @ln -sf $MDEV modem
slamr           root:dialout 0660 @ln -sf $MDEV slamr0
slusb           root:dialout 0660 @ln -sf $MDEV slusb0
fuse            root:root  0666

# misc stuff
agpgart         root:root 0660  >misc/
psaux           root:root 0660  >misc/
rtc             root:root 0664  >misc/

# input stuff
event[0-9]+     root:root 0640 =input/
ts[0-9]         root:root 0600 =input/

# v4l stuff
vbi[0-9]        root:video 0660 >v4l/
video[0-9]      root:video 0660 >v4l/

# load drivers for usb devices
usbdev[0-9].[0-9]       root:root 0660 */lib/mdev/usbdev
usbdev[0-9].[0-9]_.*    root:root 0660
EOF

git clone https://github.com/badruzeus/CloverEFI-4MU
pwd
cp /home/runner/work/cards/cards/CloverEFI-4MU/EFI /home/runner/work/cards/cards
ls
cd
dir
