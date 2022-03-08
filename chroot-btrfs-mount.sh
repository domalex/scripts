#!/bin/bash

# Script Variablen
SD=/dev/sda
FOLDER=/mnt/root

sudo mount -t btrfs -o noatime,nodiratime,compress=zstd,ssd,discard=async,subvol=aarch $SD"2" $FOLDER/ &&
sudo mount $SD"1" $FOLDER/boot/ &&
sudo mount -t btrfs -o noatime,nodiratime,compress=zstd,ssd,discard=async,nodev,nosuid,noexec,subvolid=5 $SD"2" $FOLDER/btrfs/ &&
sudo mount -t btrfs -o noatime,nodiratime,compress=zstd,ssd,discard=async,nodev,nosuid,noexec,subvol=cache $SD"2" $FOLDER/var/cache/ &&
sudo mount -t btrfs -o noatime,nodiratime,compress=zstd,ssd,discard=async,nodev,nosuid,noexec,subvol=log $SD"2" $FOLDER/var/log &&
sudo mount -t btrfs -o noatime,nodiratime,compress=zstd,ssd,discard=async,nodev,nosuid,noexec,subvol=spool $SD"2" $FOLDER/var/spool/ &&
sudo mount -t btrfs -o noatime,nodiratime,compress=zstd,ssd,discard=async,nodev,nosuid,noexec,subvol=tmp $SD"2" $FOLDER/var/tmp/ &&
sudo mount -t btrfs -o noatime,nodiratime,compress=zstd,ssd,discard=async,nodev,nosuid,noexec,subvol=images $SD"2" $FOLDER/var/lib/libvirt/images/ &&
sudo mount -t btrfs -o noatime,nodiratime,compress=zstd,ssd,discard=async,nodev,nosuid,noexec,subvol=srv $SD"2" $FOLDER/srv/ &&
sudo mount -t btrfs -o noatime,nodiratime,compress=zstd,ssd,discard=async,nodev,nosuid,noexec,subvol=root $SD"2" $FOLDER/root/ &&
sudo mount -t btrfs -o noatime,nodiratime,compress=zstd,ssd,discard=async,nodev,nosuid,noexec,subvol=home $SD"2" $FOLDER/home/ &&
sudo mount -t btrfs -o noatime,nodiratime,compress=zstd,ssd,discard=async,nodev,nosuid,noexec,subvol=downloads $SD"2" $FOLDER/home/alarm/Downloads &&
sudo mount -t btrfs -o noatime,nodiratime,compress=zstd,ssd,discard=async,nodev,nosuid,noexec,subvol=snapshots $SD"2" $FOLDER/.snapshots/ &&
cd $FOLDER

