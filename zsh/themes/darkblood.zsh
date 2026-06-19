# theme: darkbloob (from oh-my-zsh) with some minor tweaks
autoload -U colors && colors
setopt prompt_subst

# Render the venv segment ourselves instead of letting activate mangle PROMPT.
export VIRTUAL_ENV_DISABLE_PROMPT=1

venv_prompt() {
  [[ -n $VIRTUAL_ENV ]] || return
  # VIRTUAL_ENV_PROMPT is only exported by venv since Python 3.13; older
  # versions (and other tools) only set VIRTUAL_ENV, so fall back to its name.
  local name=${VIRTUAL_ENV_PROMPT:-${VIRTUAL_ENV:t}}
  # VIRTUAL_ENV_PROMPT carries surrounding parens/space; strip them for the box.
  name=${${name## }%% }
  name=${name#\(}; name=${name%\)}
  print -n -- "[%{$fg_bold[yellow]%}${name}%{$reset_color%}%{$fg[magenta]%}]"
}

# Grab the OS name from /etc/os-release once (subshell keeps env clean).
if [[ -r /etc/os-release ]]; then
  PROMPT_OS="$(. /etc/os-release && echo "${ID:-$NAME}")"
else
  PROMPT_OS="unknown"
fi

PROMPT=$'%{$fg[magenta]%}┌(%{$fg_bold[green]%}'${PROMPT_OS}$'%{$reset_color%}%{$fg[magenta]%})$(venv_prompt)[%{$fg_bold[cyan]%}%D{%a,%b%d}%{$reset_color%}%{$fg[magenta]%}] %(?,,%{$fg[red]%}[%{$fg_bold[white]%}%?%{$reset_color%}%{$fg[red]%}])
%{$fg[magenta]%}└[%{$fg_bold[blue]%}%~%{$reset_color%}%{$fg[magenta]%}]%{$fg[red]%}$%{$reset_color%} '
PS2=$' %{$fg[magenta]%}|>%{$reset_color%} '

