# vim
# build vim
sudo apt-get update
sudo apt-get install libncurses5-dev libx11-dev libxtst-dev libxt-dev libsm-dev libxpm-dev
git clone https://github.com/vim/vim.git
cd vim

# Deactivate Conda environment if activated!!!!!!
# you must configure --with-python3-config-dir for your python3 enviroment.
PYTHON3_CONFIG_DIR=/lib/python3.10/config-3.10-x86_64-linux-gnu
./configure --with-features=huge \
            --enable-multibyte \
            --disable-rubyinterp \
            --enable-python3interp \
            --with-python3-config-dir=$PYTHON3_CONFIG_DIR \
            --disable-perlinterp \
            --disable-luainterp \
            --enable-fail-if-missing \
            --prefix=/usr/local \
            --disable-gui \
            --with-x
make -j4
sudo make install
cd ..

# install plugins
sudo apt-get install curl
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
cp ./linux/.vimrc ~/
vim -c PlugInstall -c q -c q!
mkdir ~/.vim/colors
cp ~/.vim/plugged/jellybeans.vim/colors/jellybeans.vim ~/.vim/colors/
# vs code
cp ./vscode/settings.json $HOME/.config/Code/User/
