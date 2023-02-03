#!/bin/bash

# SPDX-License-Identifier:	GPL-2.0

#Simple script which starts dropbox, waits for a specific file to sync
#and stops dropbox. It can be handy or things like setting triggers in
#keepass for assuring syn on the database...

function which_dropbox()
{
	 hash dropbox-cli 2>/dev/null  && echo "dropbox-cli" || { \
	 hash caja-dropbox 2>/dev/null && echo "caja-dropbox"; }
}

#uncoment for debug
#exec 15> "$(dirname $0)/log.txt"
#BASH_XTRACEFD=15
#set -x

dropbox=$(which_dropbox)

[ -z "${dropbox}" ] && exit 0

#set the file here...
DB=$HOME/Dropbox/passwords/passwords.kdbx
let cnt=0

[ ! -f "${DB}" ] && exit 0

##start dropbox
${dropbox} start

##check if DB is in sync. Sleep to give time for the sync process to start
sleep 2
while true; do
	if [ "$(${dropbox} filestatus "${DB}" | awk -F": " '{print $2}')" == "up to date" ]; then
		let cnt+=1
		#let's give hysteresis of 3
		[ ${cnt} -eq 3 ] && break
	else
		let cnt=0	
	fi

	sleep 1
done

#have your DB offline now
${dropbox} stop
