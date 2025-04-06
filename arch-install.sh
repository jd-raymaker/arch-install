#!/bin/bash

# Function to display the main menu
display_menu() {
    clear
    echo "======================================"
    echo "      Arch Linux Installation         "
    echo "======================================"
    echo "1. List available devices"
    echo "2. Create partitions (cfdisk)"
    echo "3. Format partitions"
    echo "4. Mount partitions"
    echo "5. Continue with installation"
    echo "6. Exit"
    echo "======================================"
    echo "Current status:"
    check_mounts
    echo "======================================"
}

# Function to list available devices
list_devices() {
    clear
    echo "Available devices:"
    echo "======================================"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
    echo "======================================"
    read -n 1 -s -r -p "Press any key to continue..."
}

# Function to create partitions
create_partitions() {
    clear
    echo "Available devices:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep disk
    echo "======================================"
    read -p "Enter device to partition (e.g., sda or nvme0n1): " device
    
    if [[ -e "/dev/$device" ]]; then
        cfdisk "/dev/$device"
    else
        echo "Device /dev/$device does not exist."
        sleep 2
    fi
}

# Function to format partitions
format_partitions() {
    clear
    echo "Available partitions:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep part
    echo "======================================"
    
    read -p "Enter partition to format (e.g., sda1 or nvme0n1p1): " partition
    
    if [[ ! -e "/dev/$partition" ]]; then
        echo "Partition /dev/$partition does not exist."
        sleep 2
        return
    fi
    
    echo "Select filesystem type:"
    echo "1. ext4"
    echo "2. btrfs"
    echo "3. xfs"
    echo "4. fat32 (for EFI partition)"
    echo "5. swap"
    read -p "Enter your choice (1-5): " fs_choice
    
    case $fs_choice in
        1)
            mkfs.ext4 "/dev/$partition"
            echo "Formatted /dev/$partition as ext4."
            ;;
        2)
            mkfs.btrfs -f "/dev/$partition"
            echo "Formatted /dev/$partition as btrfs."
            ;;
        3)
            mkfs.xfs -f "/dev/$partition"
            echo "Formatted /dev/$partition as xfs."
            ;;
        4)
            mkfs.fat -F32 "/dev/$partition"
            echo "Formatted /dev/$partition as fat32."
            ;;
        5)
            mkswap "/dev/$partition"
            swapon "/dev/$partition"
            echo "Formatted /dev/$partition as swap and activated it."
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac
    
    sleep 2
}

# Function to mount partitions
mount_partitions() {
    clear
    echo "Available partitions:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep part
    echo "======================================"
    
    read -p "Enter partition to mount (e.g., sda1 or nvme0n1p1): " partition
    
    if [[ ! -e "/dev/$partition" ]]; then
        echo "Partition /dev/$partition does not exist."
        sleep 2
        return
    fi
    
    echo "Select mount point:"
    echo "1. /mnt (root partition)"
    echo "2. /mnt/boot/efi (EFI partition)"
    echo "3. Other (specify)"
    read -p "Enter your choice (1-3): " mount_choice
    
    case $mount_choice in
        1)
            mount_point="/mnt"
            ;;
        2)
            mount_point="/mnt/boot/efi"
            mkdir -p "$mount_point"
            ;;
        3)
            read -p "Enter custom mount point (will be prefixed with /mnt): " custom_mount
            mount_point="/mnt/$custom_mount"
            mkdir -p "$mount_point"
            ;;
        *)
            echo "Invalid choice."
            sleep 2
            return
            ;;
    esac
    
    mount "/dev/$partition" "$mount_point"
    echo "Mounted /dev/$partition to $mount_point."
    sleep 2
}

# Function to check if required mounts are present
check_mounts() {
    root_mounted=false
    efi_mounted=false
    
    if mount | grep -q "/mnt "; then
        root_mounted=true
        echo "[OK] Root partition mounted to /mnt"
    else
        echo "[WARN] Root partition not mounted to /mnt"
    fi
    
    if mount | grep -q "/mnt/boot/efi"; then
        efi_mounted=true
        echo "[OK] EFI partition mounted to /mnt/boot/efi"
    else
        echo "[WARN] EFI partition not mounted to /mnt/boot/efi"
    fi
}

# Main menu loop
while true; do
    display_menu
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
        1)
            list_devices
            ;;
        2)
            create_partitions
            ;;
        3)
            format_partitions
            ;;
        4)
            mount_partitions
            ;;
        5)
            if mount | grep -q "/mnt " && mount | grep -q "/mnt/boot/efi"; then
                break
            else
                echo "Error: You must mount root to /mnt and EFI to /mnt/boot/efi before continuing."
                sleep 3
            fi
            ;;
        6)
            echo "Exiting installation."
            exit 0
            ;;
        *)
            echo "Invalid choice."
            sleep 1
            ;;
    esac
done

# The rest of the installation script continues here
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

# Install the base packages
pacman -Syy
echo "Installing system.."
pacstrap /mnt base base-devel linux linux-headers linux-firmware networkmanager xorg bash-completion opendoas
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

# Generate fstab
echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

echo "First step complete, entering next step"
curl https://jd-raymaker.github.io/arch-install/arch-install-part2.sh -o /mnt/arch-install-part2.sh;
chmod +x /mnt/arch-install-part2.sh
arch-chroot /mnt ./arch-install-part2.sh

# Cleanup
rm /mnt/arch-install-part2.sh

echo "==========="
echo "DONE!"
echo "==========="
