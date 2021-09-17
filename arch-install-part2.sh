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
    cifs-utils \
    discord \
    dunst \
    efibootmgr \
    ffmpegthumbnailer \
    firefox \
    git \
    go \
    grub \
    gvfs \
    gvfs-smb \
    htop \
    i3-gaps \
    imagemagick \
    intel-ucode \
    lightdm \
    lightdm-gtk-greeter \
    lxsession \
    mpv \
    mupdf \
    neofetch \
    neovim \
    net-tools \
    nitrogen \
    nodejs \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-extra \
    npm \
    nvidia \
    nvidia-settings \
    nvidia-utils \
    openssh \
    os-prober \
    playerctl \
    polkit \
    pulseaudio \
    pulseaudio-alsa \
    pulsemixer \
    ranger \
    rofi \
    rofi-calc \
    rxvt-unicode \
    scrot \
    ttf-baekmuk \
    ttf-font-awesome \
    ttf-hack \
    ttf-hanazono \
    ttf-hannom \
    tumbler \
    udiskie \
    udisks2 \
    w3m \
    xorg-xclipboard \
    xorg-xrandr \
    xterm

# Remove that sudo package
pacman -R sudo --noconfirm
# doas takes over. Make symbolic link to replace sudo
ln -s /bin/doas /bin/sudo

echo "Enabling services.."
systemctl enable NetworkManager
systemctl enable lightdm

# Install and setup GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Check for other OS
os-prober

# Make GRUB config
grub-mkconfig -o /boot/grub/grub.cfg

# Download dotfiles
echo "Downloading dotfiles"
runuser -l $username -c 'curl https://gist.githubusercontent.com/jd-raymaker/d9e0ebb53f75a82b74ab99f044635f34/raw/5097b9c1260c4f6422b9f6ada862fa32bfe712d2/install-dotfiles | sh'

# Download and install Yay
su -P -l $username -c 'git clone https://aur.archlinux.org/yay.git $HOME/aur/yay && cd $HOME/aur/yay && makepkg -si'

# Autoinstall packages from AUR
su -P -l $username -c 'yay --noconfirm -S polybar brave-bin'

# Enable password in doas config
echo "permit persist $username" > /etc/doas.conf
