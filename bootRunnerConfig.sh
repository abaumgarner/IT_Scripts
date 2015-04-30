#----------------------------------------------------------------------------------------
# Dev: Aaron Baumgarner
# Created: 
# Description: This script is used to copy the BootRunner plist based on what disk number
#				the Windows partition is on.
#----------------------------------------------------------------------------------------
#!/bin/sh

# Queries the computer for its diskutil information, searches for the phase pased into
# grep, then cuts down the result from the search to what we are looking for which is 
# the disk number. Finally that information is stored in a local variable.
windows_Disk=$(/usr/sbin/diskutil list | grep "Microsoft Basic Data" | cut -d : -f 1)

# Checks to see what the the value is that is stored in the local variable windows_Disk.
# Based on what information is stored in the variable a new value is stored in result that
# is formatted like what you would see in Disk Utility or if the values doesn't match result
# is set to no Windows to indicate the computer is a single boot.
if [[ "${windows_Disk}" == "   3" ]]; then
	result="disk0s3"
elif [[ "${windows_Disk}" == "   4" ]]; then
	result="disk0s4"
else
    result="No Windows Disk"
fi

# Moves the plist stored locally to the Preferences directory based on the result. This sets the
# preferences for BootRunner to the correct disk with less chance of user error when typing.
mv /Users/ewua/Desktop/lect-updates/$result/com.twocanoes.bootrunner.plist /Library/Preferences/

# Exits the script safely
exit 0