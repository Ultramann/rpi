# Ubuntu

## Download
This was difficult for a couple of reasons.
1. The page I found for downloading the ubuntu image starts an automatic download when you browse to the page, this made it difficult to figure out where the url of the image was coming from and therefore hard to curl. Eventually I navigated there with w3m and the download started.
2. The image is like 670MB so it took awhile to bring down.
3. Since it was an auto download, w3m saved it to `~/.w3m` under an silly name like `w3m234ta`. So no extension info.

After figuring all this out I found this page: [cdimage.ubuntu.com/releases/20.04.01/release/]. I think it would have been easier to work with, though the discription of the various images available are still a little cryptic...

## Imagaing
All the new instructions for creating an ubuntu image for raspberry pis tell you to use the rpi imager. But of course I'm stubborn (don't have a desktop machine), so can't use it. Eventually I tried:
```
xzcat ubuntu20.img | sudo dd bs=4M of=/dev/sda conv=fsync
```
where `ubuntu20.img` was the name I gave to the `w3m...` file that got downloaded. This didn't require reformatting or reflashing the sd card, `dd` apparently took care of that. And luckily this booted first try.

## Wifi
Still having issues with this. Apparently, despite it's size, ubuntu doesn't come with many network tools preinstalled. So I tried a couple of things. Really it was just editing:
* `/etc/netplan/50-cloud-init.yaml` - adding a wifi section, and running `sudo netplan apply`
* `/etc/wpa_supplicant.conf` - adding network info and trying to restart all the system units
Neither of these worked.

At this point I kinda think the issue is with the `&` characters in the network info. So I'm going back to arch linux cause it seemed so much lighter weight.
