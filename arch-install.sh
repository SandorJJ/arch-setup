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
echo "Your disks will be formatted and all data stored will be wiped!"
confirm

echo ""
lsblk

echo -e "\nWhat is the name of the disk you want to format and partition?"
read disk

echo -e "\nAre you sure \"$disk\" is correct?"
confirm

sgdisk /dev/$disk -o

sgdisk /dev/$disk -n 0:0:+1G
sgdisk /dev/$disk -n 0:0:+1G
sgdisk /dev/$disk -n 0:0:+1G
sgdisk /dev/$disk -n 0:0:+1G
