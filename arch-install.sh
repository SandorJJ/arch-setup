#!/usr/bin/env bash
confirm () {
    echo "(y)es or (n)o"
    read input

    if [[ "$input" == "no" ]] || [[ "$input" == "n" ]] || [[ "$input" == "No" ]] || [[ "$input" == "N" ]]; then
        exit 0
    elif [[ "$input" != "yes" ]] && [[ "$input" != "y" ]] && [[ "$input" != "Yes" ]] && [[ "$input" != "Y" ]]; then
        echo "Input \"$input\" is invalid!"
        exit 2
    fi
}

echo -e "\nAre you sure you want to start arch installation?"
confirm

echo ""
lsblk

echo -e "\nWhat is the name of the disk you want to format and partition?"
read disk

efi=""
while [[ ! $efi =~ [0-9]+ ]]; do
    echo -e "\nHow many GiB should the EFI system partition be? (recommended 1 GiB)"
    read efi

    if [[ ! $efi =~ [0-9]+ ]]; then
        echo -e "\"$efi\" is invalid! Try again."
    fi
done

swap=""
while [[ ! $swap =~ [0-9]+ ]]; do
    echo -e "\nHow many GiB should the swap partition be? (recommended 4 GiB)"
    read swap

    if [[ ! $swap =~ [0-9]+ ]]; then
        echo -e "\"$swap\" is invalid! Try again."
    fi
done

root=""
while [[ ! $root =~ [0-9]+ ]]; do
    echo -e "\nHow many GiB should the root partition be? (recommended remainder (0) GiB)"
    read root

    if [[ ! $root =~ [0-9]+ ]]; then
        echo -e "\"$root\" is invalid! Try again."
    fi
done

echo -e "\nPartition layout:"
echo -e "EFI system partition - $efi GiB"
echo -e "swap partition - $swap GiB"
echo -e "root partition - $root GiB"
echo -e "Is the partition layout correct?"
confirm

echo -e "\nFormatting disk:"
sgdisk /dev/$disk -o
echo -e "\nCreating EFI system partition:"
sgdisk /dev/$disk -n 0:0:+"$efi"G
echo -e "\nCreating swap partition:"
sgdisk /dev/$disk -n 0:0:+"$swap"G
echo -e "\nCreating root partition:"
sgdisk /dev/$disk -n 0:0:+"$root"G

echo ""
lsblk

echo -e "\nWhat is the name of the EFI system partition?"
read efi_name
echo -e "\nWhat is the name of the swap partition?"
read swap_name
echo -e "\nWhat is the name of the root partition?"
read root_name

echo -e "\nFormatting EFI system partition:"
mkfs.fat -F 32 /dev/$efi_name
echo -e "\nFormatting swap partition:"
mkswap /dev/$swap_name
echo -e "\nFormatting root partition:"
mkfs.ext4 /dev/$root_name

echo -e "\nMounting EFI system partition:"
mount --mkdir /dev/$efi_name /mnt/boot
echo -e "\nEnabling swap partition:"
swapon /dev/$swap_name
echo -e "\nMounting root partition:"
mount /dev/$root_name /mnt

echo -e "\nCreating mirrorlist for downloads:"
reflector --country Canada --latest 50 --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist

echo -e "\nInstalling essential system packages:"
pacstrap -K /mnt base linux linux-firmware amd-ucode NetworkManager
echo -e "\nInstalling essential utility packages:"
pacstrap -K /mnt nmtui vim man-db

echo -e "\nGenerating fstab file:"
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
echo "Continue?"
read temp

echo -e "\nChanging root into the new system:"
arch-chroot /mnt

echo -e "\nWhat country are you in?"
read country
echo -e "\nWhat timezone are you in?"
read timezone

echo -e "\nSetting time:"
ln -sf /usr/share/zoneinfo/$country/$timezone /etc/localtime
hwclock --systohc

echo -e "\nSetting localization:"
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

echo -e "\nWhat should the device's hostname be?"
read hostname

echo -e "\nSetting hostname:"
echo "$hostname" >> /etc/hostname

echo -e "\nEnabling NetworkManager on startup:"
systemctl enable NetworkManager
