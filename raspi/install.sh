sudo apt-get update
sudo apt-get full-upgrade
sudo apt-get install -y vim tmux python3-dev python3-venv libncurses5-dev libx11-dev libxtst-dev libxt-dev libsm-dev libxpm-dev
# change symbolic link for vi
sudo rm /usr/bin/vi
sudo ln -s /usr/bin/vim /usr/bin/vi
# install plugins
sudo apt-get install -y curl
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp ./linux/.vimrc ~/
vim -c PlugInstall -c q -c q!
mkdir ~/.vim/colors
cp ~/.vim/plugged/jellybeans.vim/colors/jellybeans.vim ~/.vim/colors/
cp ../linux/.tmux.conf ~/
# edit bashrc
echo "alias ls='ls --color'" >> ~/.bashrc
echo "alias ll='ls -a'" >> ~/.bashrc
echo "export CLICOLOR=1" >> ~/.bashrc
echo "export EDITOR='vim'" >> ~/.bashrc
echo "export PS1='\\u@\\h:\\[\\e[01;32m\\]\\w\\[\\e[0m\\]\\$ '" >> ~/.bashrc
source ~/.bashrc
