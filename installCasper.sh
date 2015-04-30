#----------------------------------------------------------------------------------------
# Dev: Aaron Baumgarner
# Created: 29 April 2015
# Description: This script is used to install the Casper client located inside the 
#				FacStaff binding AppleScript. Requires that the location being executed 
#				follow the Unix naming standards, meaning no spacing in directory names 
#				leading up to the AppleScript as well as the name of the AppleScript.
#----------------------------------------------------------------------------------------

#!/bin/bash

# Changes to the location passed into the script. Only uses the first parameter passed in 
# If another parameter is passed in it is ignored
cd ""$1""

# Checks to see if the Casper client is installed based on the jamf plist that is placed
# inside the HD of the computer. If the plist exists, Casper is not installed
if [ ! -f /Library/Preferences/com.jamfsoftware.jamf.plist ]; then
	# Installs the Casper client to the computer at the root directory silently	
	installer -pkg QuickAdd.pkg -target /
fi

# Safely exits the script
exit 0