#!/bin/bash
# Backup MySQL and important asterisk files daily. Every day get's a new directory

TODAY=$(date +%u)
SOURCE="/var/lib/asterisk"
TARGET=("/mnt/var/backups/"$TODAY)
MOUNTPOINT="/mnt"
DRIVE="/dev/sdb1"
LOG="logger $0:"
RSYNCOPTS="-a --numeric-ids --delete"
RSYNC="/usr/bin/rsync"
MYDUMP="/usr/bin/mysqldump"


# check if /mnt is used and mount USB-Stick
if findmnt -m $MOUNTPOINT > /dev/null; then
  $LOG $MOUNTPOINT already in use!
  exit 1
else
  mount $DRIVE $MOUNTPOINT
  $LOG $DRIVE mounted on $MOUNTPOINT
fi


# create target directories
mkdir -p $TARGET

# backup mysql databases 
$MYDUMP --all-databases > $TARGET/mysql_dump.sql
$LOG Database dumped to $TARGET/mysql_dump.sql

# backup important asterisk files
$RSYNC $RSYNCOPTS $SOURCE $TARGET
$LOG Backup of $SOURCE created in $TARGET

# umount /mnt
umount $MOUNTPOINT
$LOG $MOUNTPOINT unmounted
