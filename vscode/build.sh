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
WITH_CROSS_COMPILE=""
WITH_LLVM="LLVM=1"
microblaze_dt=""

handle_microblaze() {
	local vivado=$(ls -d $HOME/work/Vivado_* | sort | tail -1)
	local ver="$(echo "${vivado#$HOME/work/Vivado_}" | sed 's/_R/./g')"

	[[ ! -d ${vivado} ]] && {
		echo "No Vivado installation found. Cannot build microblaze"
		exit 1;
	}

	. "${vivado}/${ver}/Vivado/settings64.sh"
	arch=microblaze
	WITH_CROSS_COMPILE="CROSS_COMPILE=microblazeel-xilinx-linux-gnu-"
	WITH_LLVM=""
}

# Lets split $1 into tokens. This matters when we use build arguments using
# the tasks.json prompt because if we have multiple arguments they will still be
# seen as 1 and set into $1. If $1 only has one value, it should not have any
# effect. Naturally we only do it if we have one argument otherwise we would overwrite
# the other arguments.
[[ -z ${2} ]] && set -- $1

case "${1}" in
"C=2"|"W=1")
	# used for sparse and W=1 builds
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
"-m")
	microblaze_dt=${2}
	;;
*)
	opt="${1}"
	# Special case for handling microblaze. Just need to care about defconfig and then
	# we can detect it below.
	[[ ${opt} == "adi_mb_defconfig" ]] && handle_microblaze
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
	elif grep -o -q CONFIG_MICROBLAZE .config; then
		handle_microblaze
		[[ -z ${opt} ]] && extra="simpleImage.${microblaze_dt}"
	else
		echo "Cannot grep any known ARCH"
		exit 1
	fi
}

make KCFLAGS="-Wno-enum-enum-conversion" ARCH=${arch} ${WITH_LLVM} ${WITH_CROSS_COMPILE} ${opt} ${file} -j$(nproc) ${extra}

