iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |` ni $HOME/vimfiles/autoload/plug.vim -Force
Copy-Item -Path ./windows/.vimrc -Destination $HOME/ -Force
