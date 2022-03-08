#!/bin/bash
# System Update
# ---------------------------
# Snapshot - Rollback - Btrfs
# ---------------------------

SUDO=/usr/bin/sudo
MV=/usr/bin/mv
BTRFS=/usr/bin/btrfs
#MOUNT=/usr/bin/mount
#UMOUNT=/usr/bin/umount
SED=/usr/bin/sed
PACMAN=/usr/bin/pacman
#PACAUR=/usr/bin/pacaur
CP=/usr/bin/cp
REFLECTOR=/usr/bin/reflector
TESTING=/btrfs/@root_TESTING
STABLE=/btrfs/@root_STABLE
OLDSTABLE=/btrfs/@root_OLDSTABLE

# ---------------------------
#      Snapshot System
# ---------------------------

# -------- OLDSTABLE --------

$SUDO $BTRFS subvolume delete $OLDSTABLE
$SUDO $MV $STABLE $OLDSTABLE
$SUDO $SED -i 's/STABLE/OLDSTABLE/g' $OLDSTABLE/etc/fstab
$SUDO $CP /boot/vmlinuz-linux-stable /boot/vmlinuz-linux-oldstable
$SUDO $CP /boot/initramfs-linux-stable.img /boot/initramfs-linux-oldstable.img

# --------- STABLE ----------
# In der nachfolgenden Zeile benutzte Nick / anstelle von $TESTING.
# Dies verursachte Probleme, wenn man das Script fälschlicherweise in einem
# anderen Subvolume als $TESTING ausführte.

$SUDO $BTRFS subvolume snapshot $TESTING $STABLE
$SUDO $SED -i 's/TESTING/STABLE/g' $STABLE/etc/fstab
$SUDO $CP /boot/vmlinuz-linux /boot/vmlinuz-linux-stable
$SUDO $CP /boot/initramfs-linux.img /boot/initramfs-linux-stable.img

# ---------------------------
#      Update System
# ---------------------------

#$SUDO $REFLECTOR --verbose -l 5 -p https --sort rate --save /etc/pacman.d/mirrorlist
$SUDO $PACMAN -Syu

# ---------------------------
#    Balance Filesystem
# ---------------------------

$SUDO $BTRFS balance start -musage=50 -dusage=50 /btrfs

