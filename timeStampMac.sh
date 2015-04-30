#----------------------------------------------------------------------------------------
# Dev: Aaron Baumgarner
# Created: 
# Description: This script is used to copy the date to a file on the HD every 900 
#				seconds.
#----------------------------------------------------------------------------------------
#! /bin/bash

# Infinite loop to get the date on the computer and save it to a file located at / every
# 900 seconds.
while(true)
do
date >> /macTimes.txt
sleep 900
done
