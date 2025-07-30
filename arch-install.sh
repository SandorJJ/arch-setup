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
while [[ ! "$efi" =~ [0-9]+ ]]; do
    echo -e "\nHow many GiB should the EFI system partition be? (recommended 1 GiB)"
    read efi

    if [[ ! "$efi" =~ [0-9]+ ]]; then
        echo -e "\"$efi\" is invalid! Try again."
    fi
done

swap=""
while [[ ! "$swap" =~ [0-9]+ ]]; do
    echo -e "\nHow many GiB should the swap partition be? (recommended 4 GiB)"
    read swap

    if [[ ! "$swap" =~ [0-9]+ ]]; then
        echo -e "\""$swap"\" is invalid! Try again."
    fi
done

root=""
while [[ ! "$root" =~ [0-9]+ ]]; do
    echo -e "\nHow many GiB should the root partition be? (recommended remainder (0) GiB)"
    read root

    if [[ ! "$root" =~ [0-9]+ ]]; then
        echo -e "\""$root"\" is invalid! Try again."
    fi
done

echo -e "\nPartition layout:"
echo -e "EFI system partition - $efi GiB"
echo -e "swap partition - $swap GiB"
echo -e "root partition - $root GiB"
echo -e "Is the partition layout correct?"
confirm

echo -e "\nFormatting disk:"
sgdisk /dev/"$disk" -o
echo -e "\nCreating EFI system partition:"
sgdisk /dev/"$disk" -n 0:0:+"$efi"GiB
sgdisk /dev/"$disk" -t 1:EF00
echo -e "\nCreating swap partition:"
sgdisk /dev/"$disk" -n 0:0:+"$swap"GiB
sgdisk /dev/"$disk" -t 2:8200
echo -e "\nCreating root partition:"
sgdisk /dev/"$disk" -n 0:0:+"$root"

echo ""
lsblk

echo -e "\nWhat is the name of the EFI system partition?"
read efi_name
echo -e "\nWhat is the name of the swap partition?"
read swap_name
echo -e "\nWhat is the name of the root partition?"
read root_name

echo "stop"
read asd

echo -e "\nFormatting EFI system partition:"
mkfs.fat -F 32 /dev/"$efi_name"
echo -e "\nFormatting swap partition:"
mkswap /dev/"$swap_name"
echo -e "\nFormatting root partition:"
mkfs.ext4 /dev/"$root_name"

echo "stop"
read asd

echo -e "\nMounting EFI system partition:"
mkdir /mnt/boot
mount /dev/"$efi_name" /mnt/boot
echo -e "\nEnabling swap partition:"
swapon /dev/"$swap_name"
echo -e "\nMounting root partition:"
mount /dev/"$root_name" /mnt

echo "stop"
read asd

echo -e "\nCreating mirrorlist for downloads:"
reflector --country Canada --latest 10 --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist

echo -e "\nInstalling essential system packages:"
pacstrap -K /mnt base linux linux-firmware 
# echo -e "\nInstalling important utility packages:"
# pacstrap -K /mnt vim git networkmanager nmtui amd-ucode man-db reflector

echo -e "\nGenerating fstab file:"
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

exit 111

echo -e "\nChanging root into the new system:"
arch-chroot /mnt

echo -e "\nWhat country are you in?"
read country
echo -e "\nWhat timezone are you in?"
read timezone

echo -e "\nSetting time:"
ln -sf /usr/share/zoneinfo/"$country"/"$timezone" /etc/localtime
hwclock --systohc

echo -e "\nSetting localization:"
locale-gen
sed -i "s/#en_US/en_US/g" /etc/locale.gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

echo -e "\nWhat should the device's hostname be?"
read hostname

echo -e "\nSetting hostname:"
echo "$hostname" >> /etc/hostname

echo -e "\nSet root password:"
passwd

echo -e "\nAdding user:"
echo -e "What should the user's username be?"
read username
useradd -m -G wheel "$username"
passwd "$username"

echo -e "\nEnabling NetworkManager on startup:"
systemctl enable NetworkManager

echo -e "\nSetting up bootloader (GRUB):"
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo -e "\nExiting from new system:"
exit
unmount -R /mnt

echo -e "\nReady to reboot (pull out USB)!"
