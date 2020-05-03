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

## Bluetooth
Configuration happens through `bluetoothctl`.

Added convience script, /usr/local/sbin/ck`, below, for easy connection to bluetooth keyboard, need to `sudo chmod +x`:
	```
	#!/bin/sh
	bluetoothctl connect $(bluetoothctl devices | grep "Cary\|Keyboard" | cut -d' ' -f2)
	```

## Keyboard:
Change file `etc/defaults/keyboard` to have `XKBLAYOUT="us"`

## Boot Sequence

### Connect to bluetooth keyboard

#### Crontab
When trying to auto connect to keyboard at boot, first tried to add to `/etc/crontab`, using script from above:
	```
	@reboot root ck
	```
On inspecting `/var/log/syslog` it seems that the crontab reboot commands run before the bluetooth device is set up.

#### rc.local
Putting full path to ck in this file runs it toward the end of the boot!
*TODO* Want to make this a system unit, cause that's the "right way" to do it.

### init.d
Seems all init.d does is softlink files into `/etc/rc<num>.d/` depending on the comment header in the init file.
It's setup with update-rc.d (or something like that), which I think just sets up those softlinks.

### rc.local
There's a file, rc.local, whos commands run after every rc.d file...I think.
