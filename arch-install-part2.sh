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
echo "$username ALL=(ALL:ALL) ALL" > /etc/sudoers.d/custom

# Install all the things!
echo "Install all the things!"
pacman -Syy --noconfirm
pacman -S --noconfirm \
    alsa-lib \
    alsa-oss \
    alsa-plugins \
    cifs-utils \
    conky \
    discord \
    dunst \
    efibootmgr \
    ffmpegthumbnailer \
    firefox \
    flameshot \
    git \
    go \
    grub \
    gvfs \
    gvfs-smb \
    htop \
    imagemagick \
    intel-ucode \
    libpulse \
    kitty \
    mpv \
    mupdf \
    neofetch \
    neovim \
    net-tools \
    nodejs \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-extra \
    npm \
    numlockx \
    openssh \
    openal \
    os-prober \
    playerctl \
    plasma \
    polkit \
    pulseaudio \
    pulseaudio-alsa \
    pulsemixer \
    python \
    python-pip \
    ranger \
    rofi \
    rofi-calc \
    rxvt-unicode \
    scrot \
    sddm \
    sddm-kcm \
    qt5-declarative \
    ttf-baekmuk \
    ttf-font-awesome \
    ttf-hack \
    ttf-hanazono \
    ttf-hannom \
    ttf-roboto-mono-nerd \
    tumbler \
    w3m \
    xcompmgr \
    xorg-xclipboard \
    xorg-xrandr \
    xorg-xwayland \
    xterm \
    zsh

echo "Enabling services.."
systemctl enable NetworkManager
systemctl enable sddm.service

# Install and setup GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Check for other OS
os-prober

# Make GRUB config
grub-mkconfig -o /boot/grub/grub.cfg

# Install zsh
chsh -s /bin/zsh $username

# Change into user
su - $username
cd ~

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install oh-my-zsh plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

