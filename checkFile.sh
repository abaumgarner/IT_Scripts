#!/bin/bash

######
# Author: Aaron Baumgarner
# Created: 10/3/16
# Modified: 9/21/20
# Notes: Checks the file the user specifies for any non ASCII characters and prints them out. Two different
#	search methods are done with grep. The first will display the character if bash can interpret it. The
#	second shows all of the characters as squares even if the first search did not show the actual character.
#	Finally the script will run word count on the file and display the division value.
#
#	9/21/20 - Added a check for single quotes
######

#COLORS
YELLOW='\033[1;33m'
NC='\033[0m'
LBLUE='\033[1;34m'

echo -e "${YELLOW}Check files for hidden characters${NC}"
echo -n "Enter File Name: "
read fname

while [ ! -f $fname ]; do
	echo -e "File ${YELLOW}$fname${NC} does not exist."
	echo ""
	echo -n "Enter File Name: "
	read fname
done


if [ -f $fname ]; then
	echo -e "${YELLOW}First Check${NC}"
	grep --color='auto' -P -n "[^\x00-\x7F]" $fname
	echo ""

	echo -e "${YELLOW}Second Check${NC}"
	LC_ALL=C grep --color='auto' -P -n '[^\00-\x7F]' $fname
	echo ""

	echo -e "${YELLOW}Third Check (Lists quotes)${NC}"
	grep --color='auto' -P -n "[^\x00-\x21,\x23-\x26,\x28-\x7F]" $fname
	echo ""
else
	echo -e "The file ${YELLOW}$fname${NC} could not be found."
fi

echo ""
echo -e "${YELLOW}Word Count${NC}"

wc $fname

wordCount=$(wc $fname)
COUNTER=0

export IFS=" "
for num in $wordCount; do
	if [ $COUNTER -eq 0 ]; then
		a=$num
	elif [ $COUNTER -eq 2 ]; then
		b=$num
	fi
	let COUNTER+=1
done

printf "$b/$a = "

res=$(bc -l <<< "scale=5; $b/$a")
echo -e "${YELLOW}$res${NC}"
