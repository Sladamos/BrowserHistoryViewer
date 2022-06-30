#!/bin/bash
# Author : Slawomir Adamowicz (sladamo@wp.pl)
# Created on : 15.04.2022
# Last Modified By : Slawomir Adamowicz (sladamo@wp.pl)
# Last Modifien On : 30.06.2022


FILE_SAVE="Don't save"
OPTION=0
FIREFOX=NO
CHROME=NO
ALL_PHRA=NO
ONE_PHRA=NO
advancedFiltering()
{
	if [[ $ALL_PHRA == YES && ! -z $PHRASES ]]; then
		TEMP=1
		TEMP2=$(echo $PHRASES | cut -d"^" -f $TEMP)
		if [[ "$PHRASES" =~ .*"^".* ]]; then
				while ! [ -z $TEMP2 ]; do
					chrourl=$(echo "${chrourl}" | grep "$TEMP2")
					fireurl=$(echo "${fireurl}" | grep "$TEMP2")
					TEMP=$(($TEMP+1))
					TEMP2=$(echo $PHRASES | cut -d"^" -f $TEMP)
				done
		else
			chrourl=$(echo "${chrourl}" | grep "$TEMP2")
			fireurl=$(echo "${fireurl}" | grep "$TEMP2")
		fi
		chrourl=$(echo "${chrourl}" | sort)
		fireurl=$(echo "${fireurl}" | sort)
	elif [[ $ONE_PHRA == YES && ! -z $PHRASES ]]; then
		TEMP=1
		TEMP2=$(echo $PHRASES | cut -d"^" -f $TEMP)
		if [[ "$PHRASES" =~ .*"^".* ]]; then
				while ! [ -z $TEMP2 ]; do
					TEMP4=$TEMP4$'\n'$(echo "${fireurl}" | grep "$TEMP2")
					TEMP3=$TEMP3$'\n'$(echo "${chrourl}" | grep "$TEMP2")
					TEMP=$(($TEMP+1))
					TEMP2=$(echo $PHRASES | cut -d"^" -f $TEMP)
				done
				chrourl=$(echo "${TEMP3}" | sort | uniq)
				fireurl=$(echo "${TEMP4}" | sort | uniq)
		else
			chrourl=$(echo "${chrourl}" | grep "$TEMP2" | uniq)
			fireurl=$(echo "${fireurl}" | grep "$TEMP2" | uniq)
		fi
	fi
}

addFileName()
{
	FILE_NAME=$(zenity --entry --title "Saving to file" --text "Enter the path of a file")
	if [[ "$FILE_NAME" =~ "~"/.* ]]; then
		TEMP=~
		FILE_NAME=$TEMP$FILE_NAME
		FILE_NAME=$(echo "$FILE_NAME" | sed 's/~//')
		elif [[ "$FILE_NAME" =~ "."/.* ]]; then
		TEMP=$(pwd)
		FILE_NAME=$TEMP$FILE_NAME
		FILE_NAME=$(echo "$FILE_NAME" | sed 's/\.//')
	fi
}

printHistory()
{
	if [[ $FIREFOX == YES && $CHROME == YES ]]; then
		TEMP=$fireurl$chrourl
		if [ "${#TEMP}" -lt "130000" ]; then
			zenity --list --title="Browsing history" --width=800 --height=500 --column=Address "FIREFOX" "${fireurl}" "CHROMIUM" "${chrourl}"
		elif [ "$FILE_SAVE" = "Don't save" ]; then
			zenity --error --text="Unable to print results because too many rows. Please save history to a file"
		fi
	elif [ $FIREFOX == YES ]; then
		if [ "${#fireurl}" -lt "130000" ]; then
			zenity --list --title="Browsing history" --width=800 --height=500 --column=Address "FIREFOX" "${fireurl}"
		elif [ "$FILE_SAVE" = "Don't save" ]; then
			zenity --error --text="Unable to print results because too many rows. Please save history to a file"
		fi
	else
		if [ "${#chrourl}" -lt "130000" ]; then
			zenity --list --title="Browsing history" --width=800 --height=500 --column=Address "CHROMIUM" "${chrourl}"
		elif [ "$FILE_SAVE" = "Don't save" ]; then
			zenity --error --text="Unable to print results because too many rows. Please save history to a file"
		fi
	fi
}

saveToFile()
{
	touch $FILE_NAME
	: > $FILE_NAME
	if [ $FIREFOX == YES ]; then
		echo "" >> $FILE_NAME
		echo FIREFOX >> $FILE_NAME
		echo "" >> $FILE_NAME
		echo "${fireurl}" >> $FILE_NAME
	fi
	if [ $CHROME == YES ]; then
		echo "" >> $FILE_NAME
		echo CHROMIUM >> $FILE_NAME
		echo "" >> $FILE_NAME
		echo "$chrourl" >> $FILE_NAME
	fi
	zenity --info --text="Results saved to file: $FILE_NAME"
}

checkHistory()
{
	if [ $FIREFOX == YES ]; then
		db=$(find "$HOME/.mozilla/firefox/" -name "places.sqlite")
		query="SELECT  datetime(h.visit_date/1000000,'unixepoch'), p.url
			FROM moz_historyvisits as h, moz_places as p 
			WHERE p.id == h.place_id
			ORDER BY h.visit_date;"
		fireurl=$(sqlite3 "$db" "$query")
		fireurl=$(echo "${fireurl}" | uniq)
	fi
	if [ $CHROME == YES ]; then
		db=~/.config/chromium/Default/History
		query="SELECT datetime(urls.last_visit_time/1000000-11644473600, \"unixepoch\") as last_visited, urls.url, urls.title
			FROM urls, visits
			WHERE urls.id = visits.url
			ORDER BY last_visited"
		chrourl=$(sqlite3 "$db" "$query")
		chrourl=$(echo "${chrourl}" | uniq)
	fi
}

realiseOption()
{
	case "$OPTION" in
		$m1)			#installing sqlite3
			if ! [ -x "$(command -v sqlite3)" ]; then
				PASSWORD=$(zenity --password --title "Root password")
				if ! [ -z $PASSWORD ]; then
				echo $PASSWORD | sudo apt update
				echo $PASSWORD | sudo apt upgrade
				echo $PASSWORD | sudo apt install sqlite3
				fi
				if ! [ -x "$(command -v sqlite3)" ]; then
					zenity --error --text="sqlite3 instalation failed"
				else
					zenity --info --text="sqlite3 instalation completed"
				fi
			else
				zenity --info --text="You already have installed sqlite3"
			fi
			;;
		$m2)			#check firefox history
			if [ $FIREFOX == NO ]; then
				FIREFOX=YES
			else
				FIREFOX=NO
			fi
			;;
		$m3)			#check chrome history
			if [ $CHROME == NO ]; then
				CHROME=YES
			else
				CHROME=NO
			fi
			;;
		$m4)			#add specific phrases
			PHRASES=$(zenity --entry --title "Search specific phrases" --text "Enter the phrases separated by "^" ")
			;;
		$m5)			#add file to save
			if [[ "$FILE_SAVE" == "Don't save" ]]; then
				FILE_SAVE="Save"
				addFileName
			else
				FILE_SAVE="Don't save"
			fi	
			;;
		$m6)			#check all phrases
			if [ $ALL_PHRA == YES ]; then
				ALL_PHRA=NO
			else
				ALL_PHRA=YES
				ONE_PHRA=NO
			fi
			;;
		$m7)			#check at least one phrase
			if [ $ONE_PHRA == YES ]; then
				ONE_PHRA=NO
			else
				ONE_PHRA=YES
				ALL_PHRA=NO
			fi
			;;
		$m8)			#checking history
			if [[ $FIREFOX == NO && $CHROME == NO ]]; then
				zenity --error --text="No browser chose"
			else
				checkHistory
				advancedFiltering
				printHistory
				if [[ "$FILE_SAVE" == "Save" ]]; then
					saveToFile
				fi
			fi
			;;
		$m9)			#removing sqlite3
			if [ -x "$(command -v sqlite3)" ]; then
				PASSWORD=$(zenity --password --title "Root password")
				if ! [ -z $PASSWORD ]; then
				echo Y | sudo apt-get remove --purge sqlite3
				fi
			else
				zenity --error --text="You don't have sqlite3"
			fi
			;;
		$m10)			#ending script
			OPTION=10
			;;
	esac
}

helper()
{
	echo "If you have troubles check if you have installed zenity. Ask your root for more help"
	OPTION=10
}

versioner()
{
	echo "Hist version is: 1.0"
	OPTION=10
}

mainMenu()
{
	while [[ $OPTION != 10 ]]; do
		m1="1. Install software sqlite3"
		m2="2. Check Firefox: $FIREFOX"
		m3="3. Check Chromium: $CHROME"
		m4="4. Add specific phrases: $PHRASES"
		if [[ "$FILE_SAVE" == "Don't save" ]]; then
		m5="5. $FILE_SAVE to file"
		else
		m5="5. $FILE_SAVE to File: $FILE_NAME"
		fi
		m6="6. Results which contain all phrases: $ALL_PHRA"
		m7="7. Results which contain at least one phrase: $ONE_PHRA"
		m8="8. Check history"
		m9="9. Uninstall software sqlite3"
		m10="10. Exit"
		MENU=("$m1" "$m2" "$m3" "$m4" "$m5" "$m6" "$m7" "$m8" "$m9" "$m10")
		OPTION=$(zenity --list --column=MENU "${MENU[@]}" --height 480 --width 640)
		realiseOption
	done
}

while getopts hvfcp: OPT; do
	case $OPT in
		h) helper;;
		v) versioner;;
		f) FIREFOX=YES;;
		c) CHROME=YES;;
		p) PHRASES=$OPTARG;;
	esac
done
mainMenu
