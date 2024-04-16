# theme: darkbloob (from oh-my-zsh) with some minor tweaks
autoload -U colors && colors
setopt prompt_subst

PROMPT=$'%{$fg[magenta]%}┌[%{$fg_bold[cyan]%}%D{%H:%M:%S}\%{$reset_color%}%{$fg[red]%}@%{$fg_bold[cyan]%}%D{%a,%b%d}%{$reset_color%}%{$fg[magenta]%}] %(?,,%{$fg[red]%}[%{$fg_bold[white]%}%?%{$reset_color%}%{$fg[red]%}])
%{$fg[magenta]%}└[%{$fg_bold[blue]%}%~%{$reset_color%}%{$fg[magenta]%}]%{$fg[red]%}$%{$reset_color%} '
PS2=$' %{$fg[magenta]%}|>%{$reset_color%} '
