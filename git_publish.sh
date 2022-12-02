#!/bin/bash -euf

# SPDX-License-Identifier:	GPL-2.0
#
# Simple script to wrap git-publish:
#	https://github.com/stefanha/git-publish
# Most of the work is just about preparing the to and cc list so
# that is nicely displayed by git-publish. Most of the times, it
# should only need to be run in the first version of the patchset.
# The script is highly inspired in:
#	https://github.com/andy-shev/home-bin-tools/blob/master/ge2maintainer.sh

set -o pipefail

usage() {
	printf "Usage $0 [options] --* [get_maintainer.pl options] -- [git-publish options]
Script to send linux patchseries via git-publish. Note that each get_maintainer.pl option is given
like '--option1 --option2'. This means that the git-publish separator '--' is mandatory for having
options for both get_maintainer.pl and git-publish.

Options:
  -c, --count		Should be the number of patches that will be included in the series.
  -l, --lkml		Include the Linux Kernel Mailing List.
  -h, --help		Display this help and exit.
	\n"

	exit 2
}

match_name() {
	__n1=$(echo "${1}" | cut -d "<" -f1)
	__n2=$(echo "${2}" | cut -d "<" -f1)

	 [[ ${__n1} == ${__n2} ]] && return 0 || return 1
}

remove_duplicates() {
	local add="y"

	for __to in ${2}; do
		for __cc in ${1}; do
			if match_name "${__cc}" "${__to}"; then
				add="n"
				break
			fi
		done

		[[ ${add} == "y" ]] && eval "$3+=(--to='${__to}')"
		add="y"
	done
}

count="1"
lkml="n"
options=""
first=""

while [ $# -ge 1 ]; do
	case $1 in
	-c|--count)
		shift
		count="$1"
		;;
	-l|--lkml)
		lkml="y"
		;;
	-h|--help)
		usage
		;;
	--)
		shift
		break;
		;;
	--*)
		options="$options $1"
		;;
	*)
		break
		;;
	esac

	shift
done

OPTS="--no-roles --no-rolestats --remove-duplicates --git --git-min-percent=67 $options"
to=$(git show -$count | scripts/get_maintainer.pl $OPTS --no-m --no-r)
cc=$(git show -$count | scripts/get_maintainer.pl $OPTS --no-l)
	
[[ ${lkml} == "y" ]] || to=${to/linux-kernel@vger.kernel.org/}

# Going with all this trouble to prepare the cc and to list to use multiple '--cc=' and
# '--to=' switches because it works better with git-publish in the sense that each email
# is displayed in it's own line making it easier to double check.
IFS=$'\n'
remove_duplicates "${cc}" "${to}" out_to
out_cc=($(sed "s/\(.*\)/--cc=\1/g" <<<"${cc}"))

git publish ${out_to[@]} ${out_cc[@]} "$@"

# everything worked... let's save the base branch so that we do not need to specify it in
# the next git-publish run
base=$(sed -n 's/.*\(--base=\|-b \)\(.*\)/\2/p' <<<"$@" | cut -d " " -f1)
already_set=$(git config branch.$(git rev-parse --abbrev-ref HEAD).gitpublishbase)
[[ -z ${base} && -z ${already_set} ]] && {
	echo "WARNING: Could not get base branch. Not saving it..."
	exit 0
}
git config branch.$(git rev-parse --abbrev-ref HEAD).gitpublishbase ${base}

