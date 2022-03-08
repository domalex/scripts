#!/bin/bash

# Backupscript für BTRFS-Server aarch auf angeschlossene USB-Festplatte
# Backup ausgewählter Partitionen und Subvolumes auf externen Datenträger

# Konzept: Es werden jeweils 3 Snapshots aufbewahrt.
# _oldest besteht einzig, damit einfacher zu einem in naher Vergangenheit liegenden, Snapshot zurückgerollt werden kann,
# ohne alle Dateien neu schreiben zu müssen. Der jeweilige read only Snapshot liegt bereits auf dem Source-Datenträger.
# Auf dem Target-Datenträger könnte prinzipiell auf _older verzichtet werden und anstelle direkt mit einem Zeitstempel _z_$DATE verfahren werden.
# Aus Gründen der Einheitlichkeit und Übersicht habe ich mich trotzdem für _older auf Beiden Datenträgern entschieden.

<<'###Mehrzeilige Komentare'
###Mehrzeilige Komentare

# -------- Überprüfung ---------
# Das Script kann als user ausgeführt werden
# Der Backup-Datenträger muss gemounted sein
# Für jedes Subvolume müssen auf dem Source- und dem Target-Datenträger drei identische Snapshots liegen: ..._new, ..._old, ..._older

#sudo -i "[ ! -d "/root/backup/bak_aarch/" ] && echo "Backup-Ziel nicht gemounted" && exit"	# Check Vorhandensein Backup-Ziel -> wird unterhalb erledigt
[ $USER != "alarm" ] && echo "Das Script als Benutzer "alarm" ausführen" && exit	# Check Benutzer

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

# Volume-Labels
VOL_BTRFS_POOL=BTRFS-POOL		# Backup Source
VOL_BACKUP=BACKUP			# Backup Target

# Mount-Pfade
SOURCE=/root/btrfs-default		# Backup Source
SNAPSHOTS=$SOURCE/snapshots		# Backup Source-Snapshots-Subvolume
SUBAK=bak_aarch				# Subvolume-Name falls innerhalb eines Subvolumes gespeichert wird und nicht im BTRFS-Default-Volume
TARGET=/root/backup/$SUBAK		# Backup Target
SRV=/srv/share/$SUBAK			# Share-Location wird nur verwendet weil für User das /root-Verzeichnis nicht zugänglich ist

# Archivierungsdatum Subvolume
#DATE=$(date +"%F_%T")

# -------------------------------
# Functions
# -------------------------------

# -------- Creation Time --------

SUSRC=aarch				# Sicherungsname = Subvolume-Source. Snapshot Root wird auch für /older_boot benötigt.

function creationTime()
{
$SUDO $BTRFS subvolume show $SNAPSHOTS/$SUSRC'_older' | $AWK '/Creation time:/ {print $3"_"$4}'
}

# --------- Überprüfung ---------

$SUDO -i [ ! -d "$TARGET" ] && echo "Backup-Ziel nicht gemounted" && exit	# Check Vorhandensein Backup-Ziel

# ---------- Snapshots ----------

SUBVOL=$SOURCE/system-pool/aarch64	# Pfad des zu sichernden Subvolumes innerhalb von $SOURCE
SUSRC=aarch				# Sicherungsname = Subvolume-Source

function snapBak()
{
#[ ! -d $SRV/$SUSRC'_older' ] || [ ! -d $SRV/$SUSRC'_old' ] || [ ! -d $SRV/$SUSRC'_new' ] && echo "Es sind nicht alle benötigten Snapshots auf dem Backup-Medium vorhanden" && exit 	# kleiner Hack: Es wird auf /srv/share ausgewichen, da als user nicht auf /root zugegriffen werden kann.
$SUDO $MV $TARGET/$SUSRC'_older' $TARGET/$SUSRC'_z_'$(creationTime)
$SUDO $MV $TARGET/$SUSRC'_old' $TARGET/$SUSRC'_older'
$SUDO $MV $TARGET/$SUSRC'_new' $TARGET/$SUSRC'_old'

#$SUDO $BTRFS subvolume delete $SNAPSHOTS/$SUSRC'_older'
$SUDO $MV $SNAPSHOTS/$SUSRC'_older' $SNAPSHOTS/$SUSRC'_z_'$(creationTime)
$SUDO $MV $SNAPSHOTS/$SUSRC'_old' $SNAPSHOTS/$SUSRC'_older'
$SUDO $MV $SNAPSHOTS/$SUSRC'_new' $SNAPSHOTS/$SUSRC'_old'

$SUDO $BTRFS subvolume snapshot -r $SUBVOL $SNAPSHOTS/$SUSRC'_new'
$SUDO $BTRFS send -p $SNAPSHOTS/$SUSRC'_old' $SNAPSHOTS/$SUSRC'_new' | $SUDO $BTRFS receive $TARGET
}

## ----------- Mount ------------
#
#$SUDO $MOUNT -t btrfs -o noatime,space_cache,compress=zstd,subvol=$SUBAK LABEL=$VOL_BACKUP $TARGET

# ------------ Boot ------------

SUSRC=aarch				# Sicherungsname = Subvolume-Source. Root wird auch für /older_boot benötigt!

#[ ! -d $SRV/$SUSRC'_older' ] || [ ! -d $SRV/$SUSRC'_old' ] || [ ! -d $SRV/$SUSRC'_new' ] && echo "Es sind nicht alle benötigten Snapshots auf dem Backup-Medium vorhanden" && exit 	# kleiner Hack: Es wird auf /srv/share ausgewichen, da als user nicht auf /root zugegriffen werden kann.
#$SUDO $RM -r $TARGET/$SUSRC'_older_boot'
$SUDO $MV $TARGET/$SUSRC'_older_boot' $TARGET/$SUSRC'_z_'$(creationTime)'_boot'
$SUDO $MV $TARGET/$SUSRC'_old_boot' $TARGET/$SUSRC'_older_boot'
$SUDO $MV $TARGET/$SUSRC'_new_boot' $TARGET/$SUSRC'_old_boot'
$SUDO $RSYNC -az --info=progress2 $SNAPSHOTS/$SUSRC'_new_boot' $TARGET

#$SUDO $RM -r $SNAPSHOTS/$SUSRC'_older_boot'
$SUDO $MV $SNAPSHOTS/$SUSRC'_older_boot' $SNAPSHOTS/$SUSRC'_z_'$(creationTime)'_boot'
$SUDO $MV $SNAPSHOTS/$SUSRC'_old_boot' $SNAPSHOTS/$SUSRC'_older_boot'
$SUDO $MV $SNAPSHOTS/$SUSRC'_new_boot' $SNAPSHOTS/$SUSRC'_old_boot'
$SUDO $RSYNC -a --info=progress2 /boot/ $SNAPSHOTS/$SUSRC'_new_boot'

# ------------------------------
# Read only Snapshots erstellen
# ------------------------------

# ------------ Root ------------

SUBVOL=$SOURCE/system-pool/aarch64	# Pfad des zu sichernden Subvolumes innerhalb von $SOURCE
SUSRC=aarch				# Sicherungsname = Subvolume-Source

snapBak

# ------------ srv -------------

SUBVOL=$SOURCE/system-pool/srv		# Pfad des zu sichernden Subvolumes innerhalb von $SOURCE
SUSRC=srv				# Sicherungsname = Subvolume-Source

#snapBak

## --------- KVM Images ---------

SUBVOL=$SOURCE/image-pool		# Pfad des zu sichernden Subvolumes innerhalb von $SOURCE
SUSRC=image-pool			# Sicherungsname = Subvolume-Source

#snapBak

## --------- ISO Pool ----------

SUBVOL=$SOURCE/iso-pool			# Pfad des zu sichernden Subvolumes innerhalb von $SOURCE
SUSRC=iso-pool				# Sicherungsname = Subvolume-Source

#snapBak

## --------- Home Root ---------
# (kein eigenes Subvolume für /root verwendet)

## ----------- Home ------------
# (kein eigenes Subvolume für /home-pool/home_aarch verwendet)

# ------------ Data ------------

SUBVOL=$SOURCE/data			# Pfad des zu sichernden Subvolumes innerhalb von $SOURCE
SUSRC=data				# Sicherungsname = Subvolume-Source

snapBak

## ---------- archive ----------

SUBVOL=$SOURCE/archive			# Pfad des zu sichernden Subvolumes innerhalb von $SOURCE
SUSRC=archive				# Sicherungsname = Subvolume-Source

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

$SUDO $BTRFS balance start -musage=50 -dusage=50 $TARGET
$SUDO $BTRFS balance start -musage=50 -dusage=50 $SOURCE

#$SUDO $UMOUNT $TARGET
