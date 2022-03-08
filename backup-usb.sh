#!/bin/bash

# Backup ausgewählter Partitionen und Subvolumes auf externen Datenträger

# ------------------------------
# Script Variablen
# ------------------------------

# Anwendungs-Pfade
SUDO=/usr/bin/sudo
CP=/usr/bin/cp
MV=/usr/bin/mv
BTRFS=/usr/bin/btrfs
RM=/usr/bin/rm
RSYNC=/usr/bin/rsync
MOUNT=/usr/bin/mount
UMOUNT=/usr/bin/umount
#SED=/usr/bin/sed

# Snapshot-Pfade
SNAPSHOTS=/btrfs/@snapshots
ARCH_NEW=$SNAPSHOTS/arch_new
ARCH_OLD=$SNAPSHOTS/arch_old
ARCH_OLDER=$SNAPSHOTS/arch_older
HOME_NEW=$SNAPSHOTS/home_new
HOME_OLD=$SNAPSHOTS/home_old
HOME_OLDER=$SNAPSHOTS/home_older
IMAGES_NEW=$SNAPSHOTS/images_new
IMAGES_OLD=$SNAPSHOTS/images_old
IMAGES_OLDER=$SNAPSHOTS/images_older

# Backup-Pfade
VOL=BACKUP
SUBAK=@NUC_archbox
BACKUP=/mnt/usb
BOOT_NEW=$BACKUP/boot_new
BOOT_OLD=$BACKUP/boot_old
BOOT_OLDER=$BACKUP/boot_older
ARCH_NEW_BAK=$BACKUP/arch_new
ARCH_OLD_BAK=$BACKUP/arch_old
ARCH_OLDER_BAK=$BACKUP/arch_older
HOME_NEW_BAK=$BACKUP/home_new
HOME_OLD_BAK=$BACKUP/home_old
HOME_OLDER_BAK=$BACKUP/home_older
IMAGES_NEW_BAK=$BACKUP/images_new
IMAGES_OLD_BAK=$BACKUP/images_old
IMAGES_OLDER_BAK=$BACKUP/images_older

# Archivierungsdatum Subvolume
DATE=$(date +"%F_%T")


# ------------------------------
# Read only Snapshots erstellen
# ------------------------------

# ----------- Mount ------------

$SUDO $MOUNT -t btrfs -o noatime,space_cache,compress=zstd,subvol=$SUBAK LABEL=$VOL $BACKUP

# ------------ Boot ------------

$SUDO $RM -r $BOOT_OLDER
$SUDO $MV $BOOT_OLD $BOOT_OLDER
$SUDO $MV $BOOT_NEW $BOOT_OLD

$SUDO $RSYNC -az /boot/ $BOOT_NEW

# ------------ Root ------------

$SUDO $BTRFS subvolume delete $ARCH_OLDER
$SUDO $MV $ARCH_OLD $ARCH_OLDER
$SUDO $MV $ARCH_NEW $ARCH_OLD

$SUDO $MV $ARCH_OLDER_BAK $ARCH_OLDER_BAK"_"$DATE
$SUDO $MV $ARCH_OLD_BAK $ARCH_OLDER_BAK
$SUDO $MV $ARCH_NEW_BAK $ARCH_OLD_BAK

$SUDO $BTRFS subvolume snapshot -r / $ARCH_NEW
$SUDO $BTRFS send -p $ARCH_OLD $ARCH_NEW | $SUDO $BTRFS receive $BACKUP

# ------------ Home ------------

$SUDO $BTRFS subvolume delete $HOME_OLDER
$SUDO $MV $HOME_OLD $HOME_OLDER
$SUDO $MV $HOME_NEW $HOME_OLD

$SUDO $MV $HOME_OLDER_BAK $HOME_OLDER_BAK"_"$DATE
$SUDO $MV $HOME_OLD_BAK $HOME_OLDER_BAK
$SUDO $MV $HOME_NEW_BAK $HOME_OLD_BAK

$SUDO $BTRFS subvolume snapshot -r /home $HOME_NEW
$SUDO $BTRFS send -p $HOME_OLD $HOME_NEW | $SUDO $BTRFS receive $BACKUP

# --------- KVM Images ---------

#$SUDO $BTRFS subvolume delete $IMAGES_OLDER
#$SUDO $MV $IMAGES_OLD $IMAGES_OLDER
#$SUDO $MV $IMAGES_NEW $IMAGES_OLD

#$SUDO $MV $IMAGES_OLDER_BAK $IMAGES_OLDER_BAK"_"$DATE
#$SUDO $MV $IMAGES_OLD_BAK $IMAGES_OLDER_BAK
#$SUDO $MV $IMAGES_NEW_BAK $IMAGES_OLD_BAK

#$SUDO $BTRFS subvolume snapshot -r /var/lib/libvirt/images $IMAGES_NEW
#$SUDO $BTRFS send -p $IMAGES_OLD $IMAGES_NEW | $SUDO $BTRFS receive $BACKUP

# ------------------------------:w

#          BTRFS scrub
# ------------------------------

# wahrscheinlich besser manuell machen um Resultat zu begutachtn
# https://blogs.oracle.com/wim/btrfs-scrub-go-fix-corruptions-with-mirror-copies-please

# ------------------------------
#       Balance Filesystem
# ------------------------------

$SUDO $BTRFS balance start -musage=50 -dusage=50 /btrfs
$SUDO $BTRFS balance start -musage=50 -dusage=50 /mnt

$SUDO $UMOUNT $BACKUP
