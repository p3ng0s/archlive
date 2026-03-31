<img src="https://github.com/p3ng0s/.github/blob/main/screenshots/logo.png?raw=true" width="100px" />

p3ng0s
=========
*p3ng0s.iso is a physical access red team platform built on Arch Linux. Boot from USB, deploy as a dropbox, crack hashes overnight, or run offline attacks against target machines*
For more information see [the wiki](https://leosmith.wtf/rice/).

## Usage
```bash
#[p4p1@archlive main/]$ ./build.sh -h
Usage:
./build.sh -a -> Support everything (This makes a big .iso don't use it)
./build.sh -o -> Multiple operator accounts.
./build.sh -b -> Build only.
./build.sh -p -> Pakcages only.
./build.sh -c -> Delete all temp folder and build folder.
./build.sh -u -> Update etc/skel to the latest content of backup.tar.xz requires a link to the file provided
./build.sh -d -> Only used for docker! do not use this!!
./build.sh -f -> Flash a USB stick with the selected iso.
Examples:
./build.sh
./build.sh -o jakob:/home/backup.tar.xz,leo:/home/backup.tar.xz
./build.sh -u http://leosmith.wtf/
./build.sh -p
./build.sh -b
./build.sh -c
./build.sh -f
./build.sh -a
```

To do a basic build do `./build.sh`

## Wallpapers

<img src="/overlay/airootfs/etc/p3ng0s/wallpaper/p3ng0s_default.png"/>
<img src="/overlay/airootfs/etc/p3ng0s/wallpaper/p3ng0s_light.png"/>
<img src="/overlay/airootfs/etc/p3ng0s/wallpaper/p3ng0s_light_not_white.png"/>
<img src="/overlay/airootfs/etc/p3ng0s/wallpaper/p3ng0s_no_text.png"/>
<img src="/overlay/airootfs/etc/p3ng0s/wallpaper/p3ng0s_notify_background.png"/>
<img src="/overlay/airootfs/etc/p3ng0s/wallpaper/p3ng0s_notify_light.png"/>
<img src="/overlay/airootfs/etc/p3ng0s/wallpaper/p3ng0s_notify_notext.png"/>
