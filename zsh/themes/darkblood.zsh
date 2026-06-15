# theme: darkbloob (from oh-my-zsh) with some minor tweaks
autoload -U colors && colors
setopt prompt_subst

# Grab the OS name from /etc/os-release once (subshell keeps env clean).
if [[ -r /etc/os-release ]]; then
  PROMPT_OS="$(. /etc/os-release && echo "${ID:-$NAME}")"
else
  PROMPT_OS="unknown"
fi

PROMPT=$'%{$fg[magenta]%}┌(%{$fg_bold[green]%}'${PROMPT_OS}$'%{$reset_color%}%{$fg[magenta]%})[%{$fg_bold[cyan]%}%D{%a,%b%d}%{$reset_color%}%{$fg[magenta]%}] %(?,,%{$fg[red]%}[%{$fg_bold[white]%}%?%{$reset_color%}%{$fg[red]%}])
%{$fg[magenta]%}└[%{$fg_bold[blue]%}%~%{$reset_color%}%{$fg[magenta]%}]%{$fg[red]%}$%{$reset_color%} '
PS2=$' %{$fg[magenta]%}|>%{$reset_color%} '
