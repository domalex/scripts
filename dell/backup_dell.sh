#!/bin/bash

# Backup ausgewählter Partitionen und Subvolumes auf externen verschlüsselten Datenträger

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
ECHO=/usr/bin/echo
GREP=/usr/bin/grep
CRYPTSETUP=/usr/bin/cryptsetup
#SED=/usr/bin/sed

# Snapshot-Pfade
SOURCE=/btrfs/@snapshots
ARCH_NEW=$SOURCE/arch_new
ARCH_OLD=$SOURCE/arch_old
ARCH_OLDER=$SOURCE/arch_older
HOME_NEW=$SOURCE/arch_home_new
HOME_OLD=$SOURCE/arch_home_old
HOME_OLDER=$SOURCE/arch_home_older
IMAGES_NEW=$SOURCE/images_new
IMAGES_OLD=$SOURCE/images_old
IMAGES_OLDER=$SOURCE/images_older

# Backup-Pfade
DEVICE=BACKUP
MAPPER=backup
KEY=/root/luks.key
VOL=BACKUP-BTRFS
#SUBAK=dell
TARGET=/mnt/backup
BOOT_NEW=$TARGET/arch_boot_new
BOOT_OLD=$TARGET/arch_boot_old
BOOT_OLDER=$TARGET/arch_boot_older
ARCH_NEW_BAK=$TARGET/arch_new
ARCH_OLD_BAK=$TARGET/arch_old
ARCH_OLDER_BAK=$TARGET/arch_older
ARCH_ARCHIVE=$TARGET/arch_z
HOME_NEW_BAK=$TARGET/arch_home_new
HOME_OLD_BAK=$TARGET/arch_home_old
HOME_OLDER_BAK=$TARGET/arch_home_older
HOME_ARCHIVE=$TARGET/arch_home_z
IMAGES_NEW_BAK=$TARGET/images_new
IMAGES_OLD_BAK=$TARGET/images_old
IMAGES_OLDER_BAK=$TARGET/images_older

# Archivierungsdatum Subvolume
DATE=$(date +"%F_%T")


# ------------------------------
# Read only Snapshots erstellen
# ------------------------------

# ----------- Mount ------------

## verschlüsselt
## Entschlüsselung und Mount wird über /etc/crypttab und /etc/fstab bewerkstelligt
#$SUDO $CRYPTSETUP open --type luks /dev/disk/by-label/$DEVICE $MAPPER --key-file $KEY
#$SUDO $MOUNT -t btrfs -o noatime,compress=zstd,ssd,nodev,nosuid,noexec,subvolid=5 /dev/mapper/$LUKSMAPPER /$TARGET

## Funktioniert nicht: " continue: nur in einer for-, while- oder until-Schleife sinnvoll"
#if $MOUNT | $GREP $TARGET > /dev/null;
#then
#	$ECHO "external backup target drive mounted" && continue
#else
#	$ECHO "please plug in external backup target drive" && exit 0
#fi

# ------------ Boot ------------

$SUDO $RM -r $BOOT_OLDER
$SUDO $MV $BOOT_OLD $BOOT_OLDER
$SUDO $MV $BOOT_NEW $BOOT_OLD

$SUDO $RSYNC -az /boot/ $BOOT_NEW

# ------------ Root ------------

$SUDO $BTRFS subvolume delete $ARCH_OLDER
$SUDO $MV $ARCH_OLD $ARCH_OLDER
$SUDO $MV $ARCH_NEW $ARCH_OLD

#$SUDO $MV $ARCH_OLDER_BAK $ARCH_OLDER_BAK"_"$DATE
$SUDO $MV $ARCH_OLDER_BAK $ARCH_ARCHIVE"_"$DATE
$SUDO $MV $ARCH_OLD_BAK $ARCH_OLDER_BAK
$SUDO $MV $ARCH_NEW_BAK $ARCH_OLD_BAK

$SUDO $BTRFS subvolume snapshot -r / $ARCH_NEW
$SUDO $BTRFS send -p $ARCH_OLD $ARCH_NEW | $SUDO $BTRFS receive $TARGET

# ------------ Home ------------

$SUDO $BTRFS subvolume delete $HOME_OLDER
$SUDO $MV $HOME_OLD $HOME_OLDER
$SUDO $MV $HOME_NEW $HOME_OLD

#$SUDO $MV $HOME_OLDER_BAK $HOME_OLDER_BAK"_"$DATE
$SUDO $MV $HOME_OLDER_BAK $HOME_ARCHIVE"_"$DATE
$SUDO $MV $HOME_OLD_BAK $HOME_OLDER_BAK
$SUDO $MV $HOME_NEW_BAK $HOME_OLD_BAK

$SUDO $BTRFS subvolume snapshot -r /home $HOME_NEW
$SUDO $BTRFS send -p $HOME_OLD $HOME_NEW | $SUDO $BTRFS receive $TARGET

# --------- KVM Images ---------

#$SUDO $BTRFS subvolume delete $IMAGES_OLDER
#$SUDO $MV $IMAGES_OLD $IMAGES_OLDER
#$SUDO $MV $IMAGES_NEW $IMAGES_OLD

#$SUDO $MV $IMAGES_OLDER_BAK $IMAGES_OLDER_BAK"_"$DATE
#$SUDO $MV $IMAGES_OLD_BAK $IMAGES_OLDER_BAK
#$SUDO $MV $IMAGES_NEW_BAK $IMAGES_OLD_BAK

#$SUDO $BTRFS subvolume snapshot -r /var/lib/libvirt/images $IMAGES_NEW
#$SUDO $BTRFS send -p $IMAGES_OLD $IMAGES_NEW | $SUDO $BTRFS receive $TARGET

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

$SUDO $UMOUNT $TARGET
$SUDO $CRYPTSETUP close $MAPPER
