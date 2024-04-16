autoload -Uz run-help

(( ${+aliases[run-help]} )) && unalias run-help
alias help=run-help

# taken from oh-my-zsh
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias -- -='cd -'

# List directory contents
alias ls='ls --color=auto'
alias lsa='ls --color=auto -lah'
alias l='ls --color=auto -lah'
alias ll='ls --color=auto -lh'
alias la='ls --color=auto -lAh'
alias lh='ls --color=auto -lh'
alias ltr='ls --color=auto -ltr'

takedir() {
	mkdir -p $@ && cd ${@:$#}
}

takegit() {
	git clone "$1"
	cd "$(basename ${1%%.git})"
}

take() {
	if [[ $1 =~ ^([A-Za-z0-9]\+@|https?|git|ssh|ftps?|rsync).*\.git/?$ ]]; then
		takegit "$1"
	else
		takedir "$@"
	fi
}

