#!/bin/bash
# System Update
# ---------------------------
# Snapshot TESTING - reate SPIELWIESE - Btrfs
# ---------------------------

SUDO=/usr/bin/sudo
#MV=/usr/bin/mv
BTRFS=/usr/bin/btrfs
#MOUNT/usr/bin/mount
#UMOUNT/usr/bin/umount
SED=/usr/bin/sed
#PACMAN=/usr/bin/pacman
#PACAUR=/usr/bin/pacaur
CP=/usr/bin/cp
#REFLECTOR=/usr/bin/reflector
TESTING=/btrfs/@root_TESTING
#STABLE=/btrfs/@root_STABLE
#OLDSTABLE=/btrfs/@root_OLDSTABLE
SPIELWIESE=/btrfs/@root_SPIELWIESE

# ---------------------------
#      Snapshot System
# ---------------------------

# -------- Delete SPIELWIESE --------

$SUDO $BTRFS subvolume delete $SPIELWIESE

# --------- Create SPIELWIESE ----------

$SUDO $BTRFS subvolume snapshot $TESTING $SPIELWIESE
$SUDO $SED -i 's/TESTING/SPIELWIESE/g' $SPIELWIESE/etc/fstab
$SUDO $CP /boot/vmlinuz-linux /boot/vmlinuz-linux-spielwiese
$SUDO $CP /boot/initramfs-linux.img /boot/initramfs-linux-spielwiese.img

# ---------------------------
#    Balance Filesystem
# ---------------------------

$SUDO $BTRFS balance start -dusage=5 /btrfs

