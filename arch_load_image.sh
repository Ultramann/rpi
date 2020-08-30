#! /bin/bash

sd_dev=/dev/sda

function print_step {
echo "----------------------------------------"
echo $1
echo "----------------------------------------"
}

if [ "$#" -ne 1 ]; then
   echo "You must pass the path to the arch linux image"
   exit
fi

sudo parted $sd_dev --script -- mklabel msdos
sudo parted $sd_dev --script -- mkpart primary fat32 1 128
sudo parted $sd_dev --script -- mkpart primary ext4 128 100%
sudo parted $sd_dev --script -- set 1 boot on
print_step "SD Card is partitioned"
sudo parted $sd_dev --script -- print
print_step "Formatting SD Card partitions"
sudo mkfs.vfat -F32 "$sd_dev"1
sudo mkfs.ext4 -F   "$sd_dev"2
print_step "Creating mount points in /mnt/arch"
sudo mkdir -p /mnt/arch/{b,r}oot
sudo mount "$sd_dev"1 /mnt/arch/boot
sudo mount "$sd_dev"2 /mnt/arch/root
print_step "Copying OS to /mnt/arch"
sudo tar -xf $1 -C /mnt/arch/root
sudo mv /mnt/arch/root/boot/* /mnt/arch/boot
print_step "Cleaning Up"
sudo umount /mnt/arch/{b,r}oot
sudo rm -rf /mnt/arch
echo "SD Card successfully formatted with image"
