#!/usr/bin/env bash
set -euf -o pipefail

TARGET_ARCH_DEFAULT="armhf"
TARGET_SUITE_DEFAULT="stable"
ADDPACKAGES_DEFAULT=""
MIRROR_DEFAULT="http://ftp.us.debian.org/debian/"

echo 
echo \> NekoBanana Rootfs Generator / Debian
echo 
echo \  This tool requires root priviliages to run,
echo \ 	You may be asked for the password for running "sudo" command.
echo
echo \ 	Please make sure that you have set up your environment.
echo \ 	The development environment can be set up according to the manual.
echo
echo \  Read more at https://github.com/amphineko/BPI-ReleaseTools
echo

echo ----------------------------------------------------------------------
echo

lsblk || true
echo
read -p "Target device (eg. /dev/sdd2) []: " TARGET_DEVICE
echo

read -p "Target system architecture [$TARGET_ARCH_DEFAULT]: " TARGET_ARCH
TARGET_ARCH=${TARGET_ARCH:-$TARGET_ARCH_DEFAULT}
echo

read -p "Distribution suite [$TARGET_SUITE_DEFAULT]: " TARGET_SUITE
TARGET_SUITE=${TARGET_SUITE:-$TARGET_SUITE_DEFAULT}
read -p "Additional packages []: " ADDPACKAGES
ADDPACKAGES=${ADDPACKAGES:-""}
echo

read -p "Mirror URL (http/https/ssh are supported) [$MIRROR_DEFAULT]: " MIRROR
MIRROR=${MIRROR:-$MIRROR_DEFAULT}
echo

echo ----------------------------------------------------------------------
echo
echo Configuration completed.
echo
echo Your data on $TARGET_DEVICE will be erased and used as root partition.
echo
read -p "Press any key to start. :3"
echo

# unmount target device
echo \# umount $TARGET_DEVICE
umount $TARGET_DEVICE || true

# make filesystem
echo \# mkfs -t ext4 $TARGET_DEVICE
mkfs -t ext4 $TARGET_DEVICE

# mount to temporary mountpoint
MOUNTPOINT=$(mktemp -d)
echo Created temporary mountpoint at $MOUNTPOINT
echo \# mount $TARGET_DEVICE $MOUNTPOINT
mount $TARGET_DEVICE $MOUNTPOINT

# debootstrap
if [ -n $ADDPACKAGES ]
then
  ADDPACKAGES="--include=$ADDPACKAGES";
fi
echo \# qemu-debootstrap --arch=$TARGET_ARCH $ADDPACKAGES $TARGET_SUITE $MOUNTPOINT $MIRROR 
qemu-debootstrap --arch=$TARGET_ARCH $ADDPACKAGES $TARGET_SUITE $MOUNTPOINT $MIRROR 
