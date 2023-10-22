alias python="python3"
alias pip="pip3"
alias ctags='/opt/homebrew/Cellar/ctags/5.8_2/bin/ctags'
alias ls='ls --color=auto'
alias ll='ls -l'
export PATH=/opt/homebrew/bin:$PATH
export EDITOR='vim'
export CLICOLOR=1

# >>> Prompt color >>>
autoload colors
colors
PROMPT="%n@%m:%{$fg[green]%}%~%{$reset_color%}$"
# <<< Prompt color <<<
