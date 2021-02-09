#!/bin/bash

echo "Remember to create partitions with fdisk or cfdisk. Format and mount them before you run this script!"
echo "Mount Main partition to /mnt"
echo "Mount EFI partition to /mnt/efi"
read -n 1 -s -r -p "Press any key to continue... (Ctrl+c Cancel)"

# Set locale for archiso
export LANG=en_US.UTF-8
export KEYMAP=no-latin1
echo en_US.UTF-8 UTF-8 > /etc/locale.gen
echo nb_NO.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
echo LANG=$LANG > /etc/locale.conf
echo KEYMAP=$KEYMAP > /etc/vconsole.conf

# Update the system clock
echo "Updating system clock"
timedatectl set-ntp true

# Mirrors
echo "Backing up original mirrorlist"
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
echo "Downloading custom mirrorlist"
curl -o /etc/pacman.d/mirrorlist 'https://gist.githubusercontent.com/jd-raymaker/9f681b31d1ce5297331b555bc001fe2c/raw/5e9b5c47140ecb2578c85272078be9c1e30ac544/ranked-mirrorlist'

# Install the base packages
pacman -Syy
echo "Installing system.."
pacstrap /mnt base base-devel linux linux-headers linux-firmware networkmanager dhcpcd xorg bash-completion opendoas
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
cp arch-install-part2.sh /mnt/arch-install-part2.sh

# Generate fstab
echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

echo "First step complete, entering next step"
arch-chroot /mnt ./arch-install-part2.sh

# Cleanup
rm /mnt/arch-install-part2.sh

echo "==========="
echo "DONE!"
echo "==========="