__last_cmd=""
__local_hist_handle() {
	__cmd=${1%%$'\n'}
	# for some reason that I don't fully understand, 'fc -W' will only write
	# the current history line into the file on the trap context. On
	# the hook context, it was not working.
	#
	# I'm also trying to mimic 'hist_ignore_dups' and 'hist_ignore_space'.
	# AFAICT, 'hist_ignore_dups' only checks the last command.
	#
	# NOTE: 'hist_ignore_space' may still need some worl. For now, only
	# empty commands are ignored.
	TRAPEXIT() {
		# This makes sure that if the same command is written two times in different panes, we
		# still don't save it in the global file which is the same as the default behavior. Let's
		# see if there's any noticeable overhead by doing this. If there is, it can be dropped as
		# it's not a "must".
		local __last_gbl_cmd=$(cat ${HISTFILE_GLOBAL} | tail -1 | cut -d";" -f2)
		[[ $__cmd != $__last_cmd ]] && [[ $__cmd != $__last_gbl_cmd ]] && [[ -n $__cmd ]] && {
			fc -p -a ${HISTFILE_GLOBAL}
			print -sr -- ${__cmd}
			__last_cmd=$__cmd
		}
	}
}

__rm_local_hist_file() {
	# removes local history file on __normal__ exit
	[[ ${HISTFILE_LOCAL} != ${HISTFILE_GLOBAL} ]] && {
		rm -f ${HISTFILE_LOCAL}
	}
}

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

HISTFILE_GLOBAL="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
[[ -n ${TMUX_PANE} ]] && {
	HISTFILE_LOCAL="$HOME/.zsh_history_${TMUX_PANE/\%/}"

	# This dance ensures that the local, per pane history file will start with
	# the same history as the global history file (at this point in time).
	fc -p ${HISTFILE_GLOBAL}
	fc -W ${HISTFILE_LOCAL}
	fc -p ${HISTFILE_LOCAL}

	autoload -Uz add-zsh-hook
	add-zsh-hook zshaddhistory __local_hist_handle
	add-zsh-hook zshexit __rm_local_hist_file
	# Need to export it so HSTR can read from it
	export HISTFILE=${HISTFILE_LOCAL}
} || HISTFILE=${HISTFILE_GLOBAL}

# HSTR configuration - add this to ~/.zshrc
alias hh=hstr                    # hh to be alias for hstr
setopt histignorespace           # skip cmds w/ leading space from history
hstr_no_tiocsti() {
    zle -I
    { HSTR_OUT="$( { </dev/tty hstr ${BUFFER}; } 2>&1 1>&3 3>&- )"; } 3>&1;
    BUFFER="${HSTR_OUT}"
    CURSOR=${#BUFFER}
    zle redisplay
}
zle -N hstr_no_tiocsti
bindkey '^[[A' hstr_no_tiocsti
export HSTR_TIOCSTI=n
export HSTR_CONFIG=hicolor,raw-history-view,prompt-bottom

