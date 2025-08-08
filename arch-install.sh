#!/usr/bin/env -S bash -e

readonly BOLD='\e[1m'
readonly RED='\e[91m'
readonly BLUE='\e[34m'  
readonly GREEN='\e[92m'
readonly YELLOW='\e[93m'
readonly RESET='\e[0m'

readonly PERCENTAGE_BAR_LENGTH=100
readonly PERCENTAGE_BAR_DIVIDER=2

readonly DEFAULT_EFI_PARTITION_SIZE=1
readonly DEFAULT_SWAP_PARTITION_SIZE=4
readonly DEFAULT_ROOT_PARTITION_SIZE=0

input=""

print_info () {
    local infos=("${@}")

    for (( i=0; i<"${#}"; i++ ))
    do
        printf "${BOLD}${BLUE}%s${RESET}\n" "${infos[i]}"
    done
}

read_input () {
    local prompt="${1}"

    printf "${BLUE}%s: ${RESET}" "${prompt}"
    read input
}

print_warning () {
    local msg="${1}"

    printf "${BOLD}${YELLOW}%s${RESET}\n" "${msg}"
}

print_percentage() {
    local percentage="${1}"
    local action="${2}"

    local bar="["
    for (( i=0; i<"${percentage}" / "${PERCENTAGE_BAR_DIVIDER}"; i++ ))
    do
        bar="${bar}#"
    done
    for (( i=0; i<("${PERCENTAGE_BAR_LENGTH}" - "${percentage}") / "${PERCENTAGE_BAR_DIVIDER}"; i++ ))
    do
        bar="${bar}-"
    done
    bar="${bar}] (${percentage}%)"

    printf "\r\e[2K"
    printf "${GREEN}%s - %s${RESET}\r" "${bar}" "${action}"

    if [[ "${percentage}" == 100 ]]; then
        printf "\n"
    fi
}

error_handler () {
    printf "${BOLD}${RED}An error has occured on line!\nCheck \"$(basename ${0} .sh).out\" for more information.${RESET}\n"
}

trap "error_handler" ERR
clear

printf "${RED}
 █████╗ ██████╗  ██████╗██╗  ██╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗
██╔══██╗██╔══██╗██╔════╝██║  ██║    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║
███████║██████╔╝██║     ███████║    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║
██╔══██║██╔══██╗██║     ██╔══██║    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║
██║  ██║██║  ██║╚██████╗██║  ██║    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                                                                               by SandorJJ
${RESET}
"

while :
do
    print_info "Start Arch Linux installation?"
    read_input "[y]es / [n]o"

    if [[ "${input}" == "y" ]] || [[ "${input}" == "Y" ]] || [[ "${input}" == "yes" ]] || [[ "${input}" == "Yes" ]]; then
        printf "\n"
        break
    elif [[ "${input}" == "n" ]] || [[ "${input}" == "N" ]] || [[ "${input}" == "no" ]] || [[ "${input}" == "No" ]]; then
        exit 0
    else
        print_warning "Invalid input: \""${input}"\", try again!"
        printf "\n"
    fi
done

lsblk
printf "\n"

disk_name=""
while :
do
    print_info "Which disk should Arch be installed on?" "WARNING: All data on the disk will be erased!"
    read_input "disk name"
    if [[ "${input}" =~ ^sd[a-z]$ ]] || [[ "${input}" =~ ^nvme[0-9]n[0-9]$ ]]; then
        disk_name="${input}"
        printf "\n"
        break
    else
        print_warning "Invalid input: \""${input}"\", try again!"
        printf "\n"
    fi
done

efi_size=""
swap_size=""
root_size=""
while :
do
    print_info "How should the disk be partitioned?" "Default: " "EFI system partition    ${DEFAULT_EFI_PARTITION_SIZE} GiB" "swap partition          ${DEFAULT_SWAP_PARTITION_SIZE} GiB" "root partition          remaining GiB"
    read_input "[enter] for default / [c]ustom"
    if [[ "${input}" == "" ]]; then
        efi_size="${DEFAULT_EFI_PARTITION_SIZE}"
        swap_size="${DEFAULT_SWAP_PARTITION_SIZE}"
        root_size="${DEFAULT_ROOT_PARTITION_SIZE}"
        printf "\n"
        break
    elif [[ "${input}" == "c" ]] || [[ "${input}" == "C" ]] || [[ "${input}" == "custom" ]] || [[ "${input}" == "Custom" ]]; then 
        printf "\n"
        while :
        do
            print_info "How large should the EFI system partition be?" "Recommended 1 GiB (default)."
            read_input "[enter] for default / partition size"
            if [[ "${input}" =~ ^[1-9][0-9]*$ ]]; then 
                efi_size="${input}"
                printf "\n"
                break
            elif [[ "${input}" == "" ]]; then
                efi_size="${DEFAULT_EFI_PARTITION_SIZE}"
                printf "\n"
                break
            else
                print_warning "Invalid input: \""${input}"\", try again!"
                printf "\n"
            fi
        done

        while :
        do
            print_info "How large should the swap partition be?" "Recommended 4 GiB (default)."
            read_input "[enter] for default / partition size"
            if [[ "${input}" =~ ^[1-9][0-9]*$ ]]; then
                swap_size="${input}"
                printf "\n"
                break
            elif [[ "${input}" == "" ]]; then
                swap_size="${DEFAULT_SWAP_PARTITION_SIZE}"
                printf "\n"
                break
            else
                print_warning "Invalid input: \""${input}"\", try again!"
                printf "\n"
            fi
        done

        while :
        do
            print_info "How large should the root partition be?" "Recommended remainder GiB (default)."
            read_input "[enter] for default / partition size"
            if [[ "${input}" =~ ^[1-9][0-9]*$ ]]; then
                root_size="${input}"
                printf "\n"
                break
            elif [[ "${input}" == "" ]]; then
                root_size="${DEFAULT_ROOT_PARTITION_SIZE}"
                printf "\n"
                break
            else
                print_warning "Invalid input: \""${input}"\", try again!"
                printf "\n"
            fi
        done
        break
    else
        print_warning "Invalid input: \""${input}"\", try again!"
        printf "\n"
    fi
done

device_name=""
while :
do
    print_info "What should this device be called?"
    read_input "device name"

    if [[ "${input}" =~ ^([a-z0-9])([a-z0-9]|-){0,62}$ ]]; then
        device_name="${input}"
        printf "\n"
        break
    else
        print_warning "Invalid input: \""${input}"\", try again!"
        printf "\n"
    fi
done

root_password=""
while :
do
    print_info "What should the root password be?"
    read_input "root password"
    password="${input}"
    read_input "repeat"
    repeat="${input}"

    if [[ "${password}" == "${repeat}" ]]; then
        root_password="${password}"
        printf "\n"
        break
    else
        print_warning "Passwords (\""${password}"\", \""${repeat}"\") don't match, try again!"
        printf "\n"
    fi
done

print_info "What should the user be called?"
read_input "user name"
user_name="${input}"

user_password=""
while :
do
    print_info "What should the user password be?"
    read_input "user password"
    password="${input}"
    read_input "repeat"
    repeat="${input}"

    if [[ "${password}" == "${repeat}" ]]; then
        user_password="${password}"
        printf "\n"
        break
    else
        print_warning "Passwords (\""${password}"\", \""${repeat}"\") don't match, try again!"
        printf "\n"
    fi
done

print_percentage 0 "Formatting disk"
sgdisk /dev/"${disk_name}" -o &> arch-install.out

print_percentage 5 "Partitioning disk"
sgdisk /dev/"${disk_name}" -n 0:0:+"${efi_size}"GiB 
sgdisk /dev/"${disk_name}" -n 0:0:+"${swap_size}"GiB 
if [[ "${root_size}" == 0 ]]; then
    sgdisk /dev/"${disk_name}" -n 0:0:+"${root_size}" 
else
    sgdisk /dev/"${disk_name}" -n 0:0:+"${root_size}"GiB 
fi

print_percentage 10 "Changing disk type"
sgdisk /dev/"${disk_name}" -t 1:EF00 
sgdisk /dev/"${disk_name}" -t 2:8200 

efi_name=""
swap_name=""
root_name=""
if [[ "${disk_name}" =~ ^sd[a-z]$ ]]; then
    efi_name="${disk_name}1"
    swap_name="${disk_name}2"
    root_name="${disk_name}3"

elif [[ "${disk_name}" =~ ^nvme[0-9]n[0-9]$ ]]; then
    efi_name="${disk_name}p1"
    swap_name="${disk_name}p2"
    root_name="${disk_name}p3"
fi

print_percentage 15 "Formatting partitions"
mkfs.fat -F 32 /dev/"${efi_name}" 
mkswap /dev/"${swap_name}" 
mkfs.ext4 /dev/"${root_name}" 

print_percentage 20 "Mounting partitions"
mount /dev/"${root_name}" /mnt 
mount --mkdir /dev/"${efi_name}" /mnt/boot 
swapon /dev/"${swap_name}" 

print_percentage 25 "Creating mirrorlist"
reflector --country Canada --latest 10 --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist  

print_percentage 40 "Installing essential system packages (may take a while)"
pacstrap -K /mnt base linux linux-firmware amd-ucode networkmanager sudo 

print_percentage 60 "Generating fstab file"
genfstab -U /mnt >> /mnt/etc/fstab 

print_percentage 65 "Setting time and localization"
arch-chroot /mnt ln -sf /usr/share/zoneinfo/"$(curl -s http://ip-api.com/line?fields=timezone)" /etc/localtime 
arch-chroot /mnt hwclock --systohc 

sed -i "s/#en_CA/en_CA/g" /mnt/etc/locale.gen 
echo "LANG=en_CA.UTF-8" > /mnt/etc/locale.conf 
arch-chroot /mnt locale-gen 

print_percentage 70 "Setting device name, root password, and generating user"
echo "${device_name}" > /mnt/etc/hostname 
echo "root:${root_password}" | arch-chroot /mnt chpasswd 
arch-chroot /mnt useradd -m -G wheel "${user_name}" 
echo "${user_name}:${user_password}" | arch-chroot /mnt chpasswd 

print_percentage 75 "Changing wheel group sudo permissions"
echo "%wheel ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers.d/00_wheel 

print_percentage 80 "Enabling networkmanager"
arch-chroot /mnt systemctl enable NetworkManager 

print_percentage 85 "Installing and setting up bootloader"
arch-chroot /mnt pacman -S --noconfirm grub efibootmgr 
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/ --bootloader-id=GRUB 
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg 

print_percentage 98 "Unmounting partitions"
cd /mnt/home/"${user_name}"
curl -Lo https://github.com/SandorJJ/arch-setup/raw/refs/heads/main/arch-setup.sh

print_percentage 95 "Unmounting partitions"
umount -R /mnt

print_percentage 100 "Arch installation complete (reboot and remove ISO)"
printf "\n"
