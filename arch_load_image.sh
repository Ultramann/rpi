#! /bin/bash

shopt -s expand_aliases
alias lb='lsblk -p -o NAME,SIZE,MOUNTPOINT'

BOLD=$(tput bold)
REG=$(tput sgr0)

SD_DEV=""

function print_step {
    echo "----------------------------------------"
    echo $1
    echo "----------------------------------------"
}

if [ "$#" -ne 1 ]; then
    echo "You must pass the path to the arch linux image"
    exit
fi

function validate_guess {
    echo "Looks like your SD card is at ${BOLD}$SD_DEV${REG}."
    while true; do
        echo "Based off the lsblk info above, does this look right? [y]es/${BOLD}[n]o${REG}/[p]rint again: "
        read -p '    ' good_guess
        if [[ $good_guess == "p" ]]; then
            lb
        elif [[ $good_guess == "yes" || $good_guess == "y" ]]; then
            return
        elif [[ $good_guess == "n" || -z $good_guess ]]; then
            SD_DEV=""
            return
        fi
        echo "Please enter \"[y]es\", \"[n]o\", or \"p\"."
    done
}

function guess {
    SD_DEV=$(lb | cut -d" " -f1 | grep "sd" | head -n 1)
}

function guess_sd_dev_name {
    guess
    if [ -z $SD_DEV ]; then echo "Could not guess name of SD device."; return; fi
    validate_guess
    if [ -z $SD_DEV ]; then return; fi
    double_check
}

function ensure_in_lsblk {
    names=$(lsblk -dnpo NAME)
    for name in $names; do
        if [[ $name == $SD_DEV ]]; then
            return
        fi
    done
    SD_DEV=""
}

function prompt_sd_dev_name {
    # TODO: make option to print lsblk here
    while [[ -z $SD_DEV ]]; do
        echo "Please enter name from lsblk output above: "
        read -p "    " SD_DEV
        ensure_in_lsblk
        if [[ ! -e $SD_DEV ]]; then
            echo "Name entered doesn't exist. Make sure you enter a top level device name."
            SD_DEV=""
            continue
        fi
        double_check
    done
}

function double_check {
    possible_root=$(lb | grep $SD_DEV | grep "/$")
    if [[ ! -z $possible_root ]]; then
        echo "It looks like the selected device might include your root file system."
        echo "Overwriting your root file system would be catastrophic."
        echo "Are you sure you want to proceed? [y]es/${BOLD}[n]o${REG}/[p]rint again: "
        read -p "    " all_good

        while true; do
            if [[ $all_good == "p" ]]; then
                lb
            elif [[ $all_good == "yes" || $all_good == "y" ]]; then
                return
            elif [[ $all_good == "no" || $all_good == "n" || -z $all_good ]]; then
                SD_DEV=""
                return
            fi
            echo "Please enter \"[y]es\", \"[n]o\", or \"p\"."
            read -p "    " all_good
        done
    fi
}

function get_sd_dev_name {
    lb
    guess_sd_dev_name
    prompt_sd_dev_name
}

function partition_sd_dev {
    print_step "Partitioning SD card"
    sudo parted $SD_DEV --script -- mklabel msdos
    sudo parted $SD_DEV --script -- mkpart primary fat32 1 128
    sudo parted $SD_DEV --script -- mkpart primary ext4 128 100%
    sudo parted $SD_DEV --script -- set 1 boot on
    print_step "SD card partitioned"
    sudo parted $SD_DEV --script -- print
}

function format_sd_partitions {
    print_step "Formatting SD card partitions"
    sudo mkfs.vfat -F32 "$SD_DEV"1
    sudo mkfs.ext4 -F   "$SD_DEV"2
}

function set_up_mounts {
    print_step "Creating mount points in /mnt/arch"
    sudo mkdir -p /mnt/arch/{b,r}oot
    sudo mount "$SD_DEV"1 /mnt/arch/boot
    sudo mount "$SD_DEV"2 /mnt/arch/root
}

function load_os_to_sd_dev {
    print_step "Copying OS to /mnt/arch"
    sudo tar -xf $1 -C /mnt/arch/root  # This is where we need to deal with cla
    sudo mv /mnt/arch/root/boot/* /mnt/arch/boot
}

function clean_up_mounts {
    print_step "Cleaning Up"
    sudo umount /mnt/arch/{b,r}oot
    sudo rm -rf /mnt/arch
}

function main {
    get_sd_dev_name
    partition_sd_dev
    format_sd_partitions
    set_up_mounts
    load_os_to_sd_dev
    clean_up_mounts
    echo "SD Card successfully formatted with image"
}

get_sd_dev_name
