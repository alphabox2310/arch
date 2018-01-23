#!/bin/bash

# Is root running this script ?                    THIS CHECK SHOULD ALWAYS BE THE FIRST CODE THAT'S EXECUTED.
if [ "`id -u`" -ne 0 ]
then
  echo -e "\n\nRun this script as root!\n\n"
  exit -1
fi


#Update the system clock
timedatectl set-ntp true

#Partition the disks / Format the partitions / Mount the file systems
parted /dev/sda
mklabel  msdos
mkpart  primary  ext4  0%  100%
set 1 boot on
quit
mkfs.ext4 /dev/sda1
mount  /dev/sda1  /mnt

#Install the base packages
pacstrap /mnt base base-devel

#Fstab
genfstab -U /mnt >> /mnt/etc/fstab

#Change Root into the new system
arch-chroot /mnt

#set correct time zone
ln  -sf  /usr/share/zoneinfo/America/New_York  /etc/localtime

hwclock --systohc

#Locale
echo 'LANG="en_US.UTF-8"' >> /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen


#Hostname
echo Arch_VM >> /etc/hostname

#Enable dhcp
systemctl enable dhcpcd.service

#Initramfs
mkinitcpio -p linux