#!/bin/bash
# System Update
# ---------------------------
# Snapshot TESTING - reate PLAYGROUND - Btrfs
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
TESTING=/btrfs/@snapshots/TESTING
#STABLE=/btrfs/@snapshots/STABLE
#OLDSTABLE=/btrfs/@snapshots/OLDSTABLE
PLAYGROUND=/btrfs/@snapshots/PLAYGROUND

# ---------------------------
#      Snapshot System
# ---------------------------

# -------- Delete PLAYGROUND --------

$SUDO $BTRFS subvolume delete $PLAYGROUND

# --------- Create PLAYGROUND ----------

$SUDO $BTRFS subvolume snapshot $TESTING $PLAYGROUND
$SUDO $SED -i 's/TESTING/PLAYGROUND/g' $PLAYGROUND/etc/fstab
$SUDO $CP /boot/vmlinuz-linux /boot/vmlinuz-linux-playground
$SUDO $CP /boot/initramfs-linux.img /boot/initramfs-linux-playground.img

# ---------------------------
#    Balance Filesystem
# ---------------------------

$SUDO $BTRFS balance start -dusage=5 /btrfs

