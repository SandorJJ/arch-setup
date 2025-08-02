#!/usr/bin/env bash
clear

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

    for (( i=0; i<${#}; i++ ))
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
    local percentage=${1}
    local action=${2}

    local bar="["
    for (( i=0; i<${percentage} / PERCENTAGE_BAR_DIVIDER; i++ ))
    do
        bar="${bar}#"
    done
    for (( i=0; i<(${PERCENTAGE_BAR_LENGTH} - ${percentage}) / PERCENTAGE_BAR_DIVIDER; i++ ))
    do
        bar="${bar} "
    done
    bar="${bar}] (${percentage}%)"

    printf "${GREEN}%s - %s${RESET}\r" "${bar}" "${action}"

    if [[ ${percentage} == 100 ]]; then
        printf "\n"
    fi
}

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
        disk_name=${input}
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
    print_info "How should the disk be partitioned?" "Default: " "EFI system partition    ${DEFAULT_EFI_PARTITION_SIZE} GiB" "swap partition          ${DEFAULT_SWAP_PARTITION_SIZE} GiB" "root partition          remainder GiB"
    read_input "[enter] for default / [c]ustom"
    if [[ "${input}" == "" ]]; then
        efi_size=${DEFAULT_EFI_PARTITION_SIZE}
        swap_size=${DEFAULT_SWAP_PARTITION_SIZE}
        root_size=${DEFAULT_ROOT_PARTITION_SIZE}
        printf "\n"
        break
    elif [[ "${input}" == "c" ]] || [[ "${input}" == "C" ]] || [[ "${input}" == "custom" ]] || [[ "${input}" == "Custom" ]]; then 
        printf "\n"
        while :
        do
            print_info "How large should the EFI system partition be?" "Recommended 1 GiB (default)."
            read_input "[enter] for default / partition size"
            if [[ "${input}" =~ ^[1-9][0-9]*$ ]]; then 
                efi_size=${input}
                printf "\n"
                break
            elif [[ "${input}" == "" ]]; then
                efi_size=${DEFAULT_EFI_PARTITION_SIZE}
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
                swap_size=${input}
                printf "\n"
                break
            elif [[ "${input}" == "" ]]; then
                swap_size=${DEFAULT_SWAP_PARTITION_SIZE}
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
                root_size=${input}
                root_size=${DEFAULT_ROOT_PARTITION_SIZE}
                printf "\n"
                break
            elif [[ "${input}" == "" ]]; then
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

print_percentage 10 "Formatting disk"
sgdisk /dev/"${disk_name}" -o &>test.out

print_percentage 20 "Partitioning disk"
sgdisk /dev/"${disk_name}" -n 0:0:+"${efi_size}"GiB &>>test.out
sgdisk /dev/"${disk_name}" -n 0:0:+"${swap_size}"GiB &>>test.out
if [[ "${root_size}" == 0 ]]; then
    sgdisk /dev/"${disk_name}" -n 0:0:+"${root_size}" &>>test.out
else
    sgdisk /dev/"${disk_name}" -n 0:0:+"${root_size}"GiB &>>test.out
fi

print_percentage 25 "Changing disk type"
sgdisk /dev/"${disk_name}" -t 1:EF00 &>>test.out
sgdisk /dev/"${disk_name}" -t 2:8200 &>>test.out

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

print_percentage 30 "Formatting partitions"
mkfs.fat -F 32 /dev/"${efi_name}" &>>test.out
mkswap /dev/"${swap_name}" &>>test.out
mkfs.ext4 /dev/"${root_name}" &>>test.out

print_percentage 40 "Mounting partitions"
mount /dev/"${root_name}" /mnt &>>test.out
mount --mkdir /dev/"${efi_name}" /mnt/boot &>>test.out
swapon /dev/"${swap_name}" &>>test.out

print_percentage 50 "Creating mirrorlist"
reflector --country Canada --latest 10 --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist &>>test.out

print_percentage 60 "Installing essential system packages"
pacstrap -K /mnt base linux linux-firmware amd-ucode

print_percentage 70 "Installing important utility packages"
pacstrap -K /mnt vim git networkmanager nmtui man-db reflector

print_percentage 75 "Generating fstab file"
genfstab -U /mnt >> /mnt/etc/fstab
