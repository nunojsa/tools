# SPDX-License-Identifier: GPL-2.0
#
# custom ~/.bashrc extensions
#

# useful alias
alias ssh_no_hosts='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
alias scp_no_hosts='scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
# this one is used in system like arch to check latest packages installed
command -v expac >/dev/null 2>&1 && alias expac='expac --timefmt "%Y-%m-%d %T" "%l\t%n" | sort'

# based on aosp. Sometimes useful but often not need when working on a git tree
cgrep() {
	find . -name .git -prune -o -type f \( -name '*.c' -o -name '*.h' -o -name '*.cpp' -o -name '*.cc' \
		-o -name '*.hpp' \) -print0 | xargs -0 grep --col -n "$@"
}

mgrep() {
	find . -name .git -prune -o -type f \( -name '*.mk' -o -name 'Makefile' \) -print0 | xargs -0 grep --colour -n "$@"
}

dtgrep() {
	find . -name .git -prune -o -type f \( -name '*.dts' -o -name '*.dtsi' \) -print0 | xargs -0 grep --colour -n "$@"
}

bbgrep() {
	find . -name .git -prune -o -type f \( -name '*.bb' -o -name '*.bbclass' -o -name '*.bbappend' -o -name '*.inc' \
		-o -name '*.conf' \) -print0 | xargs    -0 grep --colour -n "$@"
}

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

# bash history. Set to the number of commands to remember in history
HISTSIZE=20000

export PATH=$PATH:$HOME/.tools/:$HOME/.tools/git-series-push/

if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY}" ] && [ -z "${TMUX}" ]; then
	if ! systemctl --user is-active --quiet tmux.service; then
		if ! tmux ls | grep $USER | grep -q attached; then
			tmux attach-session -t "${USER}" >/dev/null 2>&1
		fi
	fi
fi
