#!/bin/bash -euf

# SPDX-License-Identifier: GPL-2.0

CFG_FILE=${1:-$HOME/.local/share/remote-connect.txt}
LOG_FILE=$HOME/.local/share/remote-connect.log

get_parameter() {
	cat ${CFG_FILE} | grep "${1}=" | sed "s/${1}=//"
}

do_connect() {
	exec ${freerdp} /u:nsa /p:"${PASSWORD}" /v:${IP_ADDR} /sound /audio-mode:1 /cert:ignore /microphone /multimon /gfx +clipboard +decorations +fonts -wallpaper 2>${LOG_FILE}
}

[[ ! -f ${CFG_FILE} ]] && {
	echo "Could not locate config file" 
	exit 1
}

freerdp=""
command -v xfreerdp3 > /dev/null && freerdp="xfreerdp3" || {
	command -v xfreerdp > /dev/null && freerdp="xfreerdp" || {
		echo "Please install the freerdp package!" 
		exit 1
	}
}

MAC_ADDR=$(get_parameter mac)
NET_ADDR=$(get_parameter net)
IP_ADDR=$(get_parameter ip)
PASSWORD=$(get_parameter password)
USER=$(get_parameter user)

# get encryption key (using zenity for getting a prompt)
descrypt_pass="$(zenity --password --title="Decryption password")"
PASSWORD=$(openssl enc -aes-256-cbc -md sha512 -a -d -pbkdf2 -salt -pass pass:${descrypt_pass} <<<${PASSWORD}) 

# fastpath: Let's do a ping for the given ip and check the arp table. If MAC matches, we're good to go...
[[ -n ${IP_ADDR} ]] && {
	ARP_MAC=""

	ping ${IP_ADDR} -c 1 > /dev/null && {
		ARP_MAC=$(arp -n | grep ${IP_ADDR} | grep -E -o '([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}')
		[[ ${ARP_MAC,,} == ${MAC_ADDR,,} ]] && {
			# we're done
			do_connect
		} || {
			cat ${CFG_FILE} | sed -i -e 's/ip.*//'  -e '/^[[:space:]]*$/d' ${CFG_FILE}
		}
	} || {
		cat ${CFG_FILE} | sed -i -e 's/ip.*//'  -e '/^[[:space:]]*$/d' ${CFG_FILE}
	}
}

command -v nmap > /dev/null || {
	echo "Please install nmap" > ${LOG_ERROR}
	exit 1
}

# Slowpath, let's run snmap...
IP_ADDR=$(pkexec nmap -sn ${NET_ADDR} | grep -C2 -i ${MAC_ADDR} | head -1 | grep -Eo '([[:digit:]]{1,3}.){3}[[:digit:]]{1,3}')
[[ -n ${IP_ADDR} ]] && echo "ip=${IP_ADDR}" >> ${CFG_FILE}

do_connect

