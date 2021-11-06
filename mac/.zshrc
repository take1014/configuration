export PATH=/opt/homebrew/bin:$PATH
#export PS1="%n@%m :: %~ "
export EDITOR='vim'
export CLICOLOR=1
autoload colors
colors
PROMPT="%n@%m:%{$fg[green]%}%~%{$reset_color%}$"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/take/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/take/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/Users/take/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/take/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

#export PATH="/usr/bin/python3:$PATH"
alias python="python3"
alias pip="pip3"