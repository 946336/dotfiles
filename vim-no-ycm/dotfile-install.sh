#!/usr/bin/env bash

retval=0

here=$(pwd)

if [ -z "$(which git)" ]; then
    echo "git not found. Installation requires git"
    retval=1
    exit retval
fi

if [ ! -e "$HOME/.vimrc" ]; then
    ln -s "$here/vimrc" "$HOME/.vimrc"
fi

if [ ! -e "$HOME/.gvimrc" ]; then
    ln -s "$here/gvimrc" "$HOME/.gvimrc"
fi

# Install powerline fonts
pushd $(mktemp -d)

git clone https://github.com/powerline/fonts.git
cd fonts
./install.sh

popd

mkdir -p "$HOME/.vim/bundle"

# Install Vundle if it isn't there
if [ ! -d $HOME/.vim/bundle/Vundle.vim ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git \
        $HOME/.vim/bundle/Vundle.vim
fi

mkdir -p "$HOME/.vim/swapfiles"
mkdir -p "$HOME/.vim/backupfiles"

vim +BundleInstall +qall

# For colorschemes
mkdir -p "$HOME/.vim/colors"
pushd $HOME/.vim/colors > /dev/null  2>&1

if [ ! -e vim-kalisi ]; then
    ln -s ../bundle/vim-kalisi .
fi

popd > /dev/null  2>&1

# Set font?
echo "xterm*font: Liberation\\ Mono\\ for\\ Powerline\\ Regular-12" \
    >> ~/.Xresources

exit $retval

