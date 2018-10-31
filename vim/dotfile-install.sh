#!/usr/bin/env bash

retval=0

here=$(pwd)

if [ ! -e "$HOME/.vimrc" ]; then
    ln -s "$here/vimrc" "$HOME/.vimrc"
fi

if [ ! -e "$HOME/.gvimrc" ]; then
    ln -s "$here/gvimrc" "$HOME/.gvimrc"
fi

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

exit $retval

