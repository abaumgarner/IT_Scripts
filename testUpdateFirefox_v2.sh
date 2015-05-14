#----------------------------------------------------------------------------------------
# Dev: Aaron Baumgarner
# Created: 
# Description: This script is used to download and install the latest version of Firefox.
#----------------------------------------------------------------------------------------
#!/bin/bash

# Queries Mozilla's website for the current version of Firefox. This only works with ##.#.#
firefox_latest_version=`/usr/bin/curl --silent https://download-installer.cdn.mozilla.net/pub/firefox/releases/latest/mac/en-US/ | grep Firefox | cut -d \> -f 7 | cut -d \< -f 1 | cut -d \  -f 2 | cut -d . -f 1-3`

echo $firefox_latest_version

# Grabs the last 3 characters in the string and stores them in a local variable
ending=${firefox_latest_version: -3}

# Checks to see if the last 3 characters are dmg. If they are it preforms another cut
# on the string to remove the .dmg and leaves only the version number. Then stores it
# back into the original variable.
if [ $ending = "dmg" ]; then
	firefox_latest_version=`echo $firefox_latest_version | cut -d . -f 1-2`
fi

echo $firefox_latest_version

# Creates the download url based on the version pulled from the website
fileURL="https://download-installer.cdn.mozilla.net/pub/firefox/releases/"$firefox_latest_version"/mac/en-US/Firefox%20"$firefox_latest_version".dmg"

# Creates an empty dmg on the local machine
firefox_dmg="/tmp/firefox.dmg"
 
#Download latest Firefox based on the url created
/usr/bin/curl --output "$firefox_dmg" "$fileURL"

#Mount the .dmg
hdiutil attach "$firefox_dmg" -nobrowse -noverify -noautoopen

#Installs Firefox
cp -r /Volumes/Firefox/Firefox.app /Applications/

#Cleanup
/usr/bin/hdiutil detach -force /Volumes/Firefox
/bin/rm -rf "$firefox_dmg"

exit 0

