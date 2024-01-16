curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp ./linux/.vimrc ~/
vim -c PlugInstall -c q -c q!
mkdir ~/.vim/colors
cp ~/.vim/plugged/jellybeans.vim/colors/jellybeans.vim ~/.vim/colors/
# vs code
cp ./vscode/settings.json $HOME/Library/Application\ Support/Code/User/
