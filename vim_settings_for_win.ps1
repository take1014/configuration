iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |` ni $HOME/vimfiles/autoload/plug.vim -Force
Copy-Item -Path ./windows/.vimrc -Destination $HOME/ -Force
vim -c PlugInstall -c q -c q!
New-Item $HOME/vimfiles/colors -ItemType Directory
Copy-Item -Path $HOME/.vim/plugged/jellybeans.vim/colors/jellybeans.vim -Destination $HOME/vimfiles/colors/
# vs code
Copy-Item -Path ".\vscode\settings.json" -Destination "$env:APPDATA\Code\User\" -Force
