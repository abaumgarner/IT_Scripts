#----------------------------------------------------------------------------------------
# Dev: Aaron Baumgarner
# Created: 29 April 2015
# Description: This script is used to sync the three names that Apple uses for computers.
#				If the three names are not the same domain binding can fail.
#----------------------------------------------------------------------------------------
#!/bin/sh

# Querries the computer for it's host name an saves it as a local variable
name=`hostname -s`

# Sets the LocalHostName to be the stored value at name
sudo scutil --set LocalHostName $name

# Sets the HostName to be the stored value at name
sudo scutil --set HostName $name

# Sets the ComputerName to be the stored value at name
sudo scutil --set ComputerName $name

# Safely exits the script
exit 0