alias python="python3"
alias pip="pip3"
alias ls='ls --color=auto'
alias ll='ls -l'
alias gls='gls --color=auto'
export EDITOR='vim'
export CLICOLOR=1

# >>> Prompt color >>>
autoload colors
colors
PROMPT="%n@%m:%{$fg[green]%}%~%{$reset_color%}$"
# <<< Prompt color <<<
