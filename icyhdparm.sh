#!/bin/bash

# Versetzt HDD in Stromsparmodus und in Tiefschlaf
sudo hdparm -B 127 /dev/disk/by-label/ICYBOX_8TB && sudo hdparm -y /dev/disk/by-label/ICYBOX_8TB
