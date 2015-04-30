#----------------------------------------------------------------------------------------
# Dev: Aaron Baumgarner
# Created: 
# Description: This script is used to download and install the latest version of Firefox.
#				However, this only works on versions that match the pattern ##.#.#
#----------------------------------------------------------------------------------------
#!/bin/bash

# Queries Mozilla's website for the current version of Firefox. This only works with ##.#.# versions and will fail on other versions (##.#).
firefox_latest_version=`/usr/bin/curl --silent https://download-installer.cdn.mozilla.net/pub/firefox/releases/latest/mac/en-US/ | grep Firefox | cut -d \> -f 7 | cut -d \< -f 1 | cut -d \  -f 2 | cut -d . -f 1-3`

# Creates the download url based on the version pulled from the website
fileURL="https://download-installer.cdn.mozilla.net/pub/firefox/releases/"$firefox_latest_version"/mac/en-US/Firefox%20"$firefox_latest_version".dmg"

# Creates an empty dmg on the local machine
firefox_dmg="/tmp/firefox.dmg"
 
#Download latest Firefox based on the url created
/usr/bin/curl --output "$firefox_dmg" "$fileURL"

#Specifies mountpoint
TMPMOUNT=`/usr/bin/mktemp -d /tmp/firefox.XXXX`

#Mount the .dmg
hdiutil attach "$firefox_dmg" -mountpoint "$TMPMOUNT" -nobrowse -noverify -noautoopen

#Installs Firefox
/usr/sbin/installer -dumplog -verbose -pkg "$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*\.pkg -o -iname \*\.mpkg \))" -target "/"
 
#Cleanup
/usr/bin/hdiutil detach "$TMPMOUNT"
/bin/rm -rf "$TMPMOUNT"
/bin/rm -rf "$flash_dmg"

