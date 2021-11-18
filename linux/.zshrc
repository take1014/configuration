alias python="python3"
alias pip="pip3"
alias ls='ls --color=auto'
alias gls='gls --color=auto'
export EDITOR='vim'
export CLICOLOR=1

# >>> Prompt color >>>
autoload colors
colors
PROMPT="%n@%m:%{$fg[green]%}%~%{$reset_color%}$"
# <<< Prompt color <<<

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/take/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/take/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/home/take/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/home/take/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
