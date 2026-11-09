$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

New-Item "$HOME/vimfiles/autoload" -ItemType Directory -Force | Out-Null
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim | ni "$HOME/vimfiles/autoload/plug.vim" -Force
Copy-Item -Path ./.vimrc -Destination $HOME/ -Force
vim -c PlugInstall -c q -c q!
New-Item "$HOME/vimfiles/colors" -ItemType Directory -Force | Out-Null
Copy-Item -Path "$HOME/.vim/plugged/jellybeans.vim/colors/jellybeans.vim" -Destination "$HOME/vimfiles/colors/" -Force
# vs code
New-Item "$env:APPDATA\Code\User" -ItemType Directory -Force | Out-Null
Copy-Item -Path "..\vscode\settings.json" -Destination "$env:APPDATA\Code\User\" -Force
