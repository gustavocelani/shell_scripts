#!/bin/bash

###############################################################################
#
#       Filename:  remount_hdd_partitions.sh
#
#    Description:  Remount HDD Partitions.
#
#        Version:  1.0
#        Created:  03/09/2020 10:03:52 PM
#       Revision:  1
#
#         Author:  Gustavo P de O Celani
#
################################################################################
#
#  File System Tab File: /etc/fstab
#  Follow fstab custom rules for remount hdd partitions at startup
#
#  # HDD Mount
#  UUID=B2DCAC5CDCAC1D1B /media/burton/HDD_A ntfs-3g defaults,nls=utf8,umask=000,dmask=027,fmask=137,uid=1000,gid=1000,windows_names 0 0
#  UUID=F838E6B238E66F56 /media/burton/HDD_B ntfs-3g defaults,nls=utf8,umask=000,dmask=027,fmask=137,uid=1000,gid=1000,windows_names 0 0
#  UUID=1A2C8E042C8DDAE1 /media/burton/HDD_C ntfs-3g defaults,nls=utf8,umask=000,dmask=027,fmask=137,uid=1000,gid=1000,windows_names 0 0
#
################################################################################

echo " "
sudo ntfsfix /dev/sdb1
sudo ntfsfix /dev/sdb2
sudo ntfsfix /dev/sdb3
echo " "

echo " "
sudo umount /media/burton/HDD_A
sudo umount /media/burton/HDD_B
sudo umount /media/burton/HDD_C
echo " "

echo " "
sudo mount -a
echo " "

