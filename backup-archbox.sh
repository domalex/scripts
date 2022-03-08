#!/bin/bash

# Backupscript für BTRFS-Desktop archbox über SSH auf einen BTRFS-Server
# Backup ausgewählter Partitionen und Subvolumes auf einen BTRFS-Server 

# Konzept: Es werden jeweils 3 Snapshots aufbewahrt.
# _oldest besteht einzig, damit einfacher zu einem in naher Vergangenheit liegenden, Snapshot zurückgerollt werden kann,
# ohne alle Dateien neu schreiben zu müssen. Der jeweilige read only Snapshot liegt bereits auf dem Source-Datenträger.
# Auf dem Target-Datenträger könnte prinzipiell auf _older verzichtet werden und anstelle direkt mit einem Zeitstempel _z_$DATE verfahren werden.
# Aus Gründen der Einheitlichkeit und Übersicht habe ich mich trotzdem für _older auf Beiden Datenträgern entschieden.

# --------- Überprüfung ---------
# Das Script sollte als user ausgeführt werden. Alternativ geht auch Root. Allerdings bedingt das viele manuelle Passworteingaben.
# Der Passwortmanager muss geöffnet sein. Der SSH-Schlüssel für Root-Zugang zum Server muss ohne Konfirmation vom Passwortmanager benutzbar sein.
# Der Backup-Datenträger muss gemouinted sein.
# Für jedes Subvolume müssen auf dem Source- und dem Target-Datenträger drei identische Snapshots liegen: ..._new, ..._old, ..._older

[ $USER != "niggi" ] && echo "Das Script als Benutzer "niggi" ausführen" && exit	# Check Benutzer

# ------------------------------
# Script Variablen Global
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
AWK=/usr/bin/awk
SSH=/usr/bin/ssh

# Volume-Labels
VOL_BTRFS_POOL=ROOT		# Backup Source
VOL_BACKUP=BACKUP		# Backup Target

# Mount-Pfade
SOURCE=/btrfs			# Backup Source
SNAPSHOTS=$SOURCE/@snapshots	# Backup Source-Snapshots-Subvolume
SUBAK=bak_nuc			# Subvolume-Name falls innerhalb eines Subvolumes gespeichert wird und nicht im BTRFS-Default-Volume
TARGET=/root/backup/$SUBAK	# Backup Target

# Client & Server Details
#PREFIX=arch			# Client-Bezeichnung (unabhängig von Client-Namen) für Backup-Names-Präfix
SERVER=aarch			# Server-Name muss in /etc/hosts und ~/.ssh/config aufgelöst werden 
USER=root			# Server-User-Name

# Archivierungsdatum Subvolume
#DATE=$(date +"%F_%T")

# -------------------------------
# Functions
# -------------------------------

# -------- Creation Time --------

SUSRC=arch				# Sicherungsname = Subvolume-Source. Snapshot Root wird auch für /older_boot benötigt.

function creationTime()
{
$SUDO $BTRFS subvolume show $SNAPSHOTS/$SUSRC'_older' | $AWK '/Creation time:/ {print $3"_"$4}'
}

# --------- Überprüfung ---------

$SSH $USER@$SERVER "[ ! -d "~/backup/bak_nuc/" ] && echo "Backup-Ziel nicht gemounted" && exit"	# Check Erreichbarkeit Backup-Ziel

# ---------- Snapshots ----------

SUBVOL=$SOURCE/@root_TESTING		# Pfad des zu sichernden Subvolumes innerhalb von $SOURCE
SUSRC=arch				# Sicherungsname = Subvolume-Source

function snapBak()
{
#$SSH $USER@$SERVER "[ ! -d $TARGET/$SUSRC'_older' ] || [ ! -d $TARGET/$SUSRC'_old' ] || [ ! -d $TARGET/$SUSRC'_new' ] && echo "Es sind nicht alle benötigten Snapshots auf dem Backup-Medium vorhanden" && exit"
$SSH $USER@$SERVER "$SUDO $MV $TARGET/$SUSRC'_older' $TARGET/$SUSRC'_z_'$(creationTime)"
$SSH $USER@$SERVER "$SUDO $MV $TARGET/$SUSRC'_old' $TARGET/$SUSRC'_older'"
$SSH $USER@$SERVER "$SUDO $MV $TARGET/$SUSRC'_new' $TARGET/$SUSRC'_old'"

#$SSH $USER@$SERVER "[ ! -d $SNAPSHOTS/$SUSRC'_older' ] || [ ! -d $SNAPSHOTS/$SUSRC'_old' ] || [ ! -d $SNAPSHOTS/$SUSRC'_new' ] && echo "Es sind nicht alle benötigten Snapshots auf dem zu sichernden Medium vorhanden" && exit"
#$SUDO $BTRFS subvolume delete $SNAPSHOTS/$SUSRC'_older
$SUDO $MV $SNAPSHOTS/$SUSRC'_older' $SNAPSHOTS/$SUSRC'_z_'$(creationTime)
$SUDO $MV $SNAPSHOTS/$SUSRC'_old' $SNAPSHOTS/$SUSRC'_older'
$SUDO $MV $SNAPSHOTS/$SUSRC'_new' $SNAPSHOTS/$SUSRC'_old'

$SUDO $BTRFS subvolume snapshot -r $SUBVOL $SNAPSHOTS/$SUSRC'_new'
$SUDO $BTRFS send -p $SNAPSHOTS/$SUSRC'_old' $SNAPSHOTS/$SUSRC'_new' | $SSH $USER@$SERVER "$SUDO $BTRFS receive $TARGET"
}

## Temporärer Ansatz
# btrfs send -p /btrfs/snapshots/arch_home_old /btrfs/snapshots/arch_home_new/ | ssh root@aarch 'btrfs receive backup/'

## -------- Local Mount --------
## Falls das Backup-Volume direkt (z.B. per USB) am Client angeschlossen wird. Allenfalls muss der Mount-Pfad ($TARGET) angepasst werden.

#$SUDO $MOUNT -t btrfs -o noatime,space_cache,compress=zstd,subvol=$SUBAK LABEL=$VOL_BACKUP $TARGET

# ------------ Boot ------------

SUSRC=arch				# Sicherungsname = Subvolume-Source. Root wird auch für /older_boot benötigt!

#$SSH $USER@$SERVER "[ ! -d $TARGET/$SUSRC'_older' ] || [ ! -d $TARGET/$SUSRC'_old' ] || [ ! -d $TARGET/$SUSRC'_new' ] && echo "Es sind nicht alle benötigten Snapshots auf dem Backup-Medium vorhanden" && exit"
#$SUDO $RM -r $TARGET/$SUSRC'_older_boot'
$SSH $USER@$SERVER "$SUDO $MV $TARGET/$SUSRC'_older_boot' $TARGET/$SUSRC'_z_'$(creationTime)'_boot'"
$SSH $USER@$SERVER "$SUDO $MV $TARGET/$SUSRC'_old_boot' $TARGET/$SUSRC'_older_boot'"
$SSH $USER@$SERVER "$SUDO $MV $TARGET/$SUSRC'_new_boot' $TARGET/$SUSRC'_old_boot'"
$SUDO $RSYNC -az --info=progress2 $SNAPSHOTS/$SUSRC'_new_boot' $USER@$SERVER:$TARGET 

#$SSH $USER@$SERVER "[ ! -d $SNAPSHOTS/$SUSRC'_older' ] || [ ! -d $SNAPSHOTS/$SUSRC'_old' ] || [ ! -d $SNAPSHOTS/$SUSRC'_new' ] && echo "Es sind nicht alle benötigten Snapshots auf dem zu sichernden Medium vorhanden" && exit"
#$SUDO $RM -r $SNAPSHOTS/$SUSRC'_older_boot'
$SUDO $MV $SNAPSHOTS/$SUSRC'_older_boot' $SNAPSHOTS/$SUSRC'_z_'$(creationTime)'_boot'
$SUDO $MV $SNAPSHOTS/$SUSRC'_old_boot' $SNAPSHOTS/$SUSRC'_older_boot'
$SUDO $MV $SNAPSHOTS/$SUSRC'_new_boot' $SNAPSHOTS/$SUSRC'_old_boot'
$SUDO $RSYNC -a --info=progress2 /boot/ $SNAPSHOTS/$SUSRC'_new_boot' 

#$SUDO $RM -r $SNAPSHOTS/$PREFIX'_older_boot'
#$SUDO $MV $SNAPSHOTS/$PREFIX'_old_boot' $SNAPSHOTS/$PREFIX'_older_boot'
#$SUDO $MV $SNAPSHOTS/$PREFIX'_new_boot' $SNAPSHOTS/$PREFIX'_old_boot'
#$SUDO $RSYNC /boot/ -a --info=progress2 $SNAPSHOTS/$PREFIX'_new_boot' 
# 
#$RSYNC -az --delete --info=progress2 $SNAPSHOTS/$PREFIX'_'*_boot $USER@$SERVER:$TARGET

# ------------------------------
# Read only Snapshots erstellen
# ------------------------------

# ------------------------------
# BTRFS send/receive
# ------------------------------
 
# ------------ Root ------------

SUBVOL=$SOURCE/@root_TESTING		# Pfad des zu sichernden Subvolumes innerhalb von $SOURCE
SUSRC=arch				# Sicherungsname = Subvolume-Source

snapBak

## --------- Home Root ---------
# (kein eigenes Subvolume für /root verwendet)

## ----------- Home ------------

SUBVOL=$SOURCE/@home			# Pfad des zu sichernden Subvolumes innerhalb von $SOURCE
SUSRC=arch_home				# Sicherungsname = Subvolume-Source

snapBak

# ------------------------------

# ------------------------------

#          BTRFS scrub
# ------------------------------

# wahrscheinlich besser manuell machen um Resultat zu begutachtn
# https://blogs.oracle.com/wim/btrfs-scrub-go-fix-corruptions-with-mirror-copies-please

# ------------------------------
#       Balance Filesystem
# ------------------------------

$SSH $USER@$SERVER "$SUDO $BTRFS balance start -musage=50 -dusage=50 $TARGET"
$SUDO $BTRFS balance start -musage=50 -dusage=50 $SOURCE

#$SUDO $UMOUNT $TARGET
