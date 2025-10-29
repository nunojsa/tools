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
patchlevel=$(cat Makefile | grep -e "PATCHLEVEL *= *[0-9]" | cut -d "=" -f2 | tr -d " ")
extra=""

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
	elif (( ${version} > "5" && ${patchlevel} > "4" )) || [[ ${arch} == "arm64" ]]; then
		file=$(sed 's;.*boot/dts/;;' <<<${file})
	else
		file=$(basename ${file})
	fi
	;;
*)
	opt="${1}"
	;;
esac

[ -f .config ] && {
	if grep -o -q CONFIG_ARM64 .config; then
		arch=arm64
		[[ -z ${opt} ]] && extra="Image compile_commands.json"
	elif grep -o -q CONFIG_ARM .config; then
		arch=arm
		# Improve this to handle RPI. We should be able to detect RPI build from .config
		[[ -z ${opt} ]] && extra="uImage UIMAGE_LOADADDR=0x8000 modules compile_commands.json"
	else
		echo "Cannot grep any known ARCH"
		exit 1
	fi
}

make KCFLAGS="-Wno-enum-enum-conversion" ARCH=${arch} LLVM=1 ${opt} ${file} -j$(nproc) ${extra}

