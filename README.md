# arch-install
Semi-Automatic Arch install with personal setup. Made for UEFI systems in mind.

## How to use
1. Clone repo `git clone https://github.com/jd-raymaker/arch-install.git` and edit it to your liking
2. Partition and format drives you want to use with any tool of your choice (ex. cfdisk or fdisk)
3. Mount the root partition to `/mnt`
4. Make a mount point for EFI partition `mkdir /mnt/efi`
5. Mount EFI partition to `/mnt/efi`
6. Run `./arch-install.sh` and watch the installation do it's magic