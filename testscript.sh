#!/bin/bash

#out="/root/btrfs-default/snapshots";echo "$out"/*_z_*
#out="/root/btrfs-default/snapshots"; sudo btrfs su li -o "$out"/*_z_*
#find /root/btrfs-default/snapshots/ -maxdepth 1 -name "*_z_*" -type f -print0
for archivesrc in "/root/btrfs-default/snapshots"; do
	sudo btrfs su li -o "$archivesrc"/*_z_*
done

