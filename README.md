## TODO
* Make bluetooth connection sysstem unit, currently in rc.local.
* Set TERM to xterm-256color
* Emacs
    * Projectile
    * Deamon, will reload work in this?

## Changefont
	```
	sudo dpkg-reconfigure console-setup
	```
This auto changed the font on the current terminal, but supposedly it needs `setupcon`
to be run for the changes to take effect.

Configuration lives at `etc/default/console-setup`.

## Local Time
Running `date` seems just to look at the file `/etc/localtime`. So you can just update that file. Seems like `localtime` is just a softlink to one of many files that have timezone info in them.
	```
	sudo ln -s /usr/share/zoneinfo/America/Denver /etc/localtime
	```

## SSH
	```
	sudo systemctl enable ssh && sudo systemctl start ssh
	```
## Emacs
## Daemon
### Currently Not Using, Using Screen Instead
*It seems that moving between dired directories quits out of the buffer, so it closes the emacs client session*

Run: `systemctl --user enable emacs`. This seems to symlink from `~/config/systemd/user/default.target.wants/emacs.service' to '/usr/lib/systemd/user/emacs.service`.

So it seems that there's user specific systemd settings kept in `~/conf/systemd/user` and that programs like emacs save their default system units to `/usr/lib/systemd`. The fact that emacs was in `/usr/lib/systemd/user` probably is what lead systemctl to make a `~/config/systemd/user` directory when I asked it to enable emacs for my user.

### Screen
`sudo apt install screen`

To get emacs colors working had to add `~/.sreenrc` file with: `term xterm-256color`.
Since I'm only really using it to keep emacs running between sessions, also added this alias to `.bashrc`: `alias screen='screen -R emacs'`.

### w3m
Install w3m: `sudo apt-get install w3m`.

## Docker
Installation instructions mostly from:
	`https://withblue.ink/2019/07/13/yes-you-can-run-docker-on-raspbian.html`

### Install
	```
	sudo apt update
	sudo apt install -y \
	     apt-transport-https \
	     ca-certificates \
	     curl \
	     gnupg2 \
	     software-properties-common
	
	curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
	echo "deb [arch=armhf] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
	     $(lsb_release -cs) stable" | \
	    sudo tee /etc/apt/sources.list.d/docker.list
	
	sudo apt update
	sudo apt install -y --no-install-recommends \
	    docker-ce \
	    cgroupfs-mount
	
	sudo systemctl enable docker
	sudo systemctl start docker
	
	sudo usermod -aG docker ${USER}
	```

### Add User to Docker Group
`sudo usermod -aG docker <user_name>`

### Install Docker Compose
No install for arm, can install with pip
	```
	sudo apt update
	sudo apt install -y python3-pip libffi-dev
	sudo pip3 install docker-compose
	```

## Bluetooth
Configuration happens through `bluetoothctl`.

Added convience script, /usr/local/sbin/ck`, below, for easy connection to bluetooth keyboard, need to `sudo chmod +x`:
	```
	#!/bin/sh
	bluetoothctl connect $(bluetoothctl devices | grep "Cary\|Keyboard" | cut -d' ' -f2)
	```

## Keyboard:
Change file `etc/defaults/keyboard` to have:
* `XKBLAYOUT="us"`
* `XKBOPTIONS="caps:escape"`

## Boot Sequence

### Connect to bluetooth keyboard

#### Crontab
When trying to auto connect to keyboard at boot, first tried to add to `/etc/crontab`, using script from above:
	```
	@reboot root ck
	```
On inspecting `/var/log/syslog` it seems that the crontab reboot commands run before the bluetooth device is set up.

#### rc.local
Putting full path to ck in this file runs it toward the end of the boot! *Currently not using. Have Pok3r wired in instead.*

## init.d
Seems all init.d does is softlink files into `/etc/rc<num>.d/` depending on the comment header in the init file.
It's setup with update-rc.d (or something like that), which I think just sets up those softlinks.

## rc.local
There's a file, rc.local, whos commands run after every rc.d file...I think.

## systemd.service

`man systemd.service`
