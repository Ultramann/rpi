# Arch Linux

## Installation
Followed instructions from [here](https://linuxize.com/post/how-to-install-arch-linux-on-raspberry-pi/), with the only differences being I installed the most recent version of arch linux arm for rpi 4 from [here](http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-4-latest.tar.gz) and the name of the sd card when plugged into my rpi was not `sdb` but `sda`. So all refereces were changed accordingly.

## Arch Wiki for RPi
<https://archlinuxarm.org/wiki/Raspberry_Pi>

## Wifi
Do all the below as root, since I'm assuming you don't have internet and therefore no `sudo` yet.
1. Run `wifi-menu -o` the `-o` will...obscure the password, so it's encrypted on disk
  * When it asks for a name for the network give it something simple like: `home`
  * Once you finish there should be a file: `/etc/netctl/home` which has the login info (obscured)
  * You should be connected to the wifi now, you can check with: `ip a` you should see an `inet` section under `wlan0` with an ip address

2. Enable auto connection at boot with: `systemctl enable netctl-auto@wlan0.service`
  * You can check the list of profiles that `netctl-auto` will try to connect to with `netctl-auto list`
  * You can choose which profile you connect with via: `netctl-auto switch-to <profile_name>`

## DNS Resolution
It seems our AT&T router was overwriting `/etc/resolv.conf` when the wifi connected. This lead to domain names not getting resolved. After reading the arch wiki for DNS resolution [here](https://wiki.archlinux.org/index.php/Domain_name_resolution#Glibc_resolver), I hard-coded the `/etc/resolv.conf` file to:
```
search domain.name
nameserver 8.8.8.8
nameserver 1.1.1.1
nameserver 1.0.0.1
```
And then set the file to be write protected from programs as the wiki suggests with:
```
chattr +i /etc/resolv.conf
```

## Stop Audit Logs
Add `audit=0` to end of line in `/boot/cmdline.txt`

## Update System
```
pacman -Syu
```

## Install Base Packages
```
pacman -S man-db sudo git
```

## Display Setup
Add overscan lines to `/boot/config.txt`. See video section of RPi arch wiki for some more details

## Timezone
```
timedatectl set-timezone America/Chicago
```

## User

1. Add user, `-m` makes a directory under `/home`:
```
useradd -m cary
```
2. Add password, user account doesn't come with a password. Creating the password is interactive:
```
passwd cary
```
3. Give `sudo` permission:
  1. Run `visudo` as root
  2. Add line:
  ```
  cary ALL=(ALL) NOPASSWD: ALL  
  ```

## Install Others
```
pacman -S xorg-xinit xorg-server xf86-video-fbdev emacs w3m
```

## Add Font
Add Menlo:
```
mkdir -p /urs/share/fonts/type1/gsfonts
cd !$
curl -O https://raw.githubusercontent.com/hbin/top-programming-fonts/master/Menlo-Regular.ttf
fc-cache -fv
fc-list
```
