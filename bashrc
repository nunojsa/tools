# SPDX-License-Identifier: GPL-2.0
#
# custom ~/.bashrc extensions
#

os_name() {
	cat /etc/os-release  | grep -E -o ^ID=.* | cut -d"=" -f2
}

TURQUOISE="\[$(tput setaf 6)\]"
KIND_OF_BLUE="\[$(tput setaf 12)\]"
RED="\[$(tput setaf 1)\]"
RESET="\[$(tput sgr0)\]"

PS1="${KIND_OF_BLUE}($(os_name)) ${TURQUOISE}\u@\W${RED}\$${RESET} "
unset TURQUOISE
unset RED
unset KIND_OF_BLUE
unset RESET

. $HOME/.tools/commonrc

# bash history. Set to the number of commands to remember in history
HISTSIZE=20000

export PATH=$PATH:$HOME/.tools/:$HOME/.tools/git-series-push/
