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
		-o -name '*.hpp' \) -print0 | xargs -0 grep --col   our -n "$@"
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

if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY}" ] && [ -z "${TMUX}" ]; then
	if ! systemctl --user is-active --quiet tmux.service; then
		systemctl --user start tmux.service
	fi

	if ! tmux ls | grep $USER | grep -q attached; then
		tmux attach-session -t "${USER}" >/dev/null 2>&1
	fi
fi

# bash history. Set to the number of commands to remember in history
HISTSIZE=20000

export PATH=$PATH:$HOME/.tools/
