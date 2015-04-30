#----------------------------------------------------------------------------------------
# Dev: Aaron Baumgarner
# Created: 
# Description: This script is used to download and install the latest version of Chrome.
#----------------------------------------------------------------------------------------
#!/bin/bash

# Sets the url path to the Chrome dmg
fileURL="https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"

# Creates an empty dmg on the local machine.
chrome_dmg="/tmp/chrome.dmg"

# Downloads the dmg at the url path and saved into the empty dmg
/usr/bin/curl -Lo "$chrome_dmg" "$fileURL"

# Mounts the dmg silently
hdiutil attach "$chrome_dmg" -nobrowse -noverify -noautoopen

# Copies the application in the dmg to the Applications directory or "installs" Chrome
cp -r /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/

# Unmounts the dmg
/usr/bin/hdiutil detach -force /Volumes/Google\ Chrome

# Removes the dmg once the script is done
/bin/rm -rf "$chrome_dmg"

# Exits the script safely
exit 0
