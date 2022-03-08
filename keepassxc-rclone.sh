#!/bin/bash
rclone mount --vfs-cache-mode full dropbox-crypt:db_niggi/ ~/c-kp/ & 
/usr/bin/keepassxc &&
fusermount -u ~/c-kp/
