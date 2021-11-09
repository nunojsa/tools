#!/bin/bash

# this script is intended to build the linux kernel under vscode. It can be called
# from tasks.json with the proper parameters. As I use this to mainly compile ADI
# kernel, I try to find a proper Vivado installation to get the toolchain. However,
# one can use any toolchain he wants as long as the proper env variables are passed.

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
	if [[ ${arch} == "arm64" ]]; then
		file=$(sed 's;.*boot/dts/;;' <<<${file})
	else
		file=$(basename ${file})
	fi

	# check for overlays...
	[[ ${file} =~ .*-overlay.dtb ]] && file="overlays/"$(sed 's/-overlay.dtb//' <<<${file})".dtbo"
	;;
*)
	opt="${1}"
	;;
esac

# this env should be set in task.json if we don't want to look for a vivado instalation
[[ ${no_vivado} != "y" ]] && {
	# get vivado toolchains from the kernel version
	if [[ ${full_ver} == "4.19" ]]; then
		vivado="$HOME/work/Vivado_2019_R1/Vivado/2019.1/settings64.sh"
	else
		# default to the latest which is 5.4 kernel
		vivado="$HOME/work/Vivado_2020_R1/Vivado/2020.1/settings64.sh"
	fi

	[[ -f ${vivado} ]] && source ${vivado}
}

make ARCH=${arch} CROSS_COMPILE=${cross_compile} ${opt} ${file} -j$(nproc)
