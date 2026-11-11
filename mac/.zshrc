alias python="python3"
alias pip="pip3"
alias ll='ls -l'
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
export EDITOR='vim'
export CLICOLOR=1

# >>> Prompt color >>>
autoload colors
colors
PROMPT="%n@%m:%{$fg[green]%}%~%{$reset_color%}$"
# <<< Prompt color <<<
