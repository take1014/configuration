curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp ./mac/.vimrc ~/
vim -c PlugInstall -c q -c q!
mkdir ~/.vim/colors
cp ~/.vim/plugged/jellybeans.vim/colors/jellybeans.vim ~/.vim/colors/
