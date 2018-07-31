#!/usr/bin/env bash

retval=0

# Really?
home=`echo ~`
here=$(pwd)

if [ ! -e "$home/.vimrc" ]; then
    ln -s "$here/vimrc" "$home/.vimrc"
fi

if [ ! -e "$home/.gvimrc" ]; then
    ln -s "$here/gvimrc" "$home/.gvimrc"
fi

mkdir -p "$home/.vim/bundle"

# Install Vundle if it isn't there
if [ ! -d $home/.vim/bundle/Vundle.vim ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git \
        $home/.vim/bundle/Vundle.vim
fi

# Really???
HOME="$home" vim +BundleInstall +qall

# For colorschemes
mkdir -p "$home/.vim/colors"
pushd $home/.vim/colors > /dev/null  2>&1

if [ ! -e vim-kalisi ]; then
    ln -s ../bundle/vim-kalisi .
fi

popd > /dev/null  2>&1

exit $retval

