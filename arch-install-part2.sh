#!/bin/bash

# Set locale
export LANG=en_US.UTF-8
export KEYMAP=no-latin1

# Set time zone
ln -sf /usr/share/zoneinfo/Europe/Oslo /etc/localtime
hwclock --systohc

# Localization
mv /etc/locale.gen /etc/locale.gen_backup
echo en_US.UTF-8 UTF-8 > /etc/locale.gen
echo nb_NO.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
echo LANG=$LANG > /etc/locale.conf
echo KEYMAP=$KEYMAP > /etc/vconsole.conf

# Set hostname and configure hosts
echo "Configuring network"
echo "Enter Hostname: "
read hostname
echo $hostname > /etc/hostname
echo 127.0.0.1 localhost > /etc/hosts
echo ::1 localhost >> /etc/hosts
echo 127.0.1.1 $hostname.localdomain $hostname >> /etc/hosts

# Set root password
echo "Set root password"
passwd

# Create user
echo "Enter new username"
read username
useradd -m $username
echo "Make password for $username"
passwd $username

# Add the user to sudoers
# echo "$username ALL=(ALL:ALL) ALL" > /etc/sudoers.d/custom
# Who needs sudo? Lets use doas
# don't use password during setup. We enable password again when finished
echo "permit nopass $username" > /etc/doas.conf

# Install all the things!
echo "Install all the things!"
pacman -Syu --noconfirm && pacman -S --noconfirm \
    git \
    xorg-xrandr \
    scrot \
    rofi \
    rofi-calc \
    dunst \
    nitrogen \
    ranger \
    go \
    xorg-xclipboard \
    rxvt-unicode \
    lxsession \
    polkit \
    i3-gaps \
    lightdm \
    lightdm-gtk-greeter \
    xterm \
    neovim \
    firefox \
    intel-ucode \
    amd-ucode \
    grub \
    efibootmgr \
    os-prober \
    xf86-video-fbdev

# Remove that sudo package
pacman -R sudo --noconfirm
# doas takes over. Make symbolic link to replace sudo
ln -s /bin/doas /bin/sudo

mkinitcpio -P

echo "Enabling services.."
systemctl enable dhcpcd.service
systemctl enable lightdm.service

# Install and setup GRUB

# esp is either under /efi or /boot
[ -d "/efi" ] && esp=/efi || esp=/boot
grub-install --target=x86_64-efi --efi-directory=$esp --bootloader-id=GRUB

# Check for other OS
os-prober

# Make GRUB config
grub-mkconfig -o /boot/grub/grub.cfg

# Download dotfiles
echo "Downloading dotfiles"
runuser -l $username -c 'curl https://gist.githubusercontent.com/jd-raymaker/d9e0ebb53f75a82b74ab99f044635f34/raw/5097b9c1260c4f6422b9f6ada862fa32bfe712d2/install-dotfiles | sh'

# Download and install Yay
runuser -l $username -c 'git clone https://aur.archlinux.org/yay.git $HOME/aur/yay'
su -l $username -c 'cd $HOME/aur/yay && makepkg -si' -P
# Download and install polybar
runuser -l $username -c 'got clone https://aur.archlinux.org/polybar.git $HOME/aur/polybar'
su -l $username -c 'cd $HOME/aur/polybar && makepkg -si' -P

# Enable password in doas config again
echo "permit persist $username" > /etc/doas.conf
