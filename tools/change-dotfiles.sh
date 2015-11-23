#!/bin/bash

cd ~
git clone git@bitbucket.org:tro3373/dotfiles.git dotfiles.new
mv dotfiles/ dotfiles.old
mv dotfiles.new dotfiles

mv ~/dotfiles.old/apps/zsh/tmp dotfiles/apps/zsh/
if [ -e ~/dotfiles.old/apps/ssh/.ssh ]; then
    mv ~/dotfiles.old/apps/ssh/.ssh ~/dotfiles/apps/ssh/
fi
cd ~/dotfiles/
./inst.sh exec vim
