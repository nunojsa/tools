# SPDX-License-Identifier: GPL-2.0

# On fedora, docker completions can be found in here. Needs to
# be before compinit.
#
# Also note that in arch the cli docker complete is not available at all.
# It looks like the default will be to use:
#   'echo "source <(docker completion zsh)" >> ~/.zshrc'
# But for the time being the old one still works better so I'll use it. Since
# this is likely temporary, on arch, I just manually downloaded the "legacy"
# script and placed it in $HOME/zsh. Keep an eye on this!
[[ -f "/usr/share/zsh/vendor-completions/_docker" ]] && {
	fpath=(/usr/share/zsh/vendor-completions/_docker $fpath)
	zstyle ':completion:*:*:docker:*' option-stacking yes
	zstyle ':completion:*:*:docker-*:*' option-stacking yes
}

() {
	local git_comp=""

	if [[ -f /usr/share/doc/git/contrib/completion/git-completion.zsh ]]; then
		git_comp="/usr/share/doc/git/contrib/completion/git-completion.zsh"
	elif [[ -f /usr/share/git/completion/git-completion.zsh ]]; then
		git_comp="/usr/share/git/completion/git-completion.zsh"
	else
		echo "No git completions..."
		return 1
	fi

	# so that we do not miss updates
	cp ${git_comp} $HOME/.zsh/_git
	fpath=($HOME/.zsh $fpath)

	zstyle ':completion:*:*:git:*' tag-order ''
	sed -i '/.*_requested alias-commands.*/d' $HOME/.zsh/_git
	sed -i "s,\(.*_requested common-commands.*\),\
		\t_requested alias-commands \&\& __git_zsh_cmd_alias\n\1," $HOME/.zsh/_git
}

zmodload zsh/complist
autoload -Uz compinit; compinit
_comp_options+=(globdots)

command -v tig >/dev/null && {
	# For tig automplete. First source the bash tig completion. We set a
	# "no-op" for __git_complete so the tig bash completion script does not
	# complain. Then, tell zsh to use _git for tig.
	local tig_bash="$(pkg-config --variable=completionsdir bash-completion)/tig"
	if [[ -f "${tig_bash}" ]]; then
		local old="$functions[__git_complete]"
		functions[__git_complete]=:
		. ${tig_bash}
		functions[__git_complete]="$old"
		compdef _git tig
	fi
}

down-autocd-or-line-or-menu() {
	if [[ $#BUFFER == 0 ]]; then
		BUFFER="cd "
		CURSOR=3
		zle list-choices
	elif [[ $RBUFFER == *$'\n'* ]]; then
		zle down-line
	else
		zle menu-select
	fi
}
zle -N down-autocd-or-line-or-menu
bindkey '^[[B' down-autocd-or-line-or-menu

zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/compcache"

zstyle -e ':completion:*' completer _expand _complete _correct _approximate _prefix _ignored
zstyle ':completion:*' menu select
zstyle ':completion:*:*:*:*:descriptions' format '%B%F{white}%d %f%b'
zstyle ':completion:*:warnings' format ' %F{red}no matches found...%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order alias builtins functions commands

zstyle ':completion:*' file-sort modification
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*:cd:*' complete-options yes
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

zstyle ':completion:*:parameters' extra-verbose yes
zstyle ':completion:*:history-lines'  format ''

zstyle ':completion:*' insert-sections yes
zstyle ':completion:*' separate-sections yes

setopt COMPLETE_IN_WORD
setopt LIST_PACKED
setopt LIST_ROWS_FIRST
LISTMAX=0
