#!/bin/bash

# SPDX-License-Identifier:	GPL-2.0

# this script is intended to build the linux kernel under vscode. It can be called
# from tasks.json with the proper parameters. As I use this to mainly compile ADI
# kernel, I try to find a proper Vivado installation to get the toolchain. However,
# one can use any toolchain he wants as long as the proper env variables are passed.
set -e

opt=""
vivado=""
version=$(cat Makefile | grep -e "VERSION *= *[0-9]" | cut -d "=" -f2 | tr -d " ")
patchevel=$(cat Makefile | grep -e "PATCHLEVEL *= *[0-9]" | cut -d "=" -f2 | tr -d " ")
full_ver="${version}.${patchevel}"

case "${1}" in
"C=2")
	# used for sparse
	file=${2/.c/.o}
	file=$(sed "s;${PWD}/;;" <<<${file})
	opt="${1}"
	;;
"-d")
	file=${2/.dts/.dtb}
	if [[ ${file} =~ .*-overlay.dtb ]]; then
		file="overlays/"$(sed 's/-overlay.dtb//' <<<$(basename ${file}))".dtbo"
	elif [[ ${full_ver} > "6.4" || ${arch} == "arm64" ]]; then
		file=$(sed 's;.*boot/dts/;;' <<<${file})
	else
		file=$(basename ${file})
	fi
	;;
*)
	opt="${1}"
	;;
esac

# this env should be set in task.json if we don't want to look for a vivado installation
[[ ${no_vivado} != "y" ]] && {
	vivado=$(ls -d $HOME/work/Vivado_* | sort | tail -1)

	# I'm aware this will break if Xilinx changes the directory tree but using 'find'
	# was taking some __annoying__ time so I prefer fix this (if I ever have to) when
	# the time comes...
	[[ -d ${vivado} ]] && source ${vivado}/Vivado/*/settings64.sh
}

make ARCH=${arch} CROSS_COMPILE=${cross_compile} CC=clang ${opt} ${file} -j$(nproc)
