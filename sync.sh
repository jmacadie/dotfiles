#!/bin/bash

# Get the full path to this script
SCRIPT=$(readlink -f $0)
DIR="${SCRIPT%/*}"

# First check all the dirs are in place
mkdir -p $HOME/.config
mkdir -p $HOME/.zsh
mkdir -p $HOME/.local/bin

# Remove any pre-exisitng files
rm -f $HOME/.gitconfig
rm -f $HOME/.tmux.conf
rm -f $HOME/.zshrc
rm -rf $HOME/.zsh
rm -r $HOME/.local/bin/t
rm -r $HOME/.local/bin/tt
rm -r $HOME/.local/bin/gbt
rm -f $HOME/.config/starship.toml
rm -rf $HOME/.config/nvim

# Add the files as symlinks to this repo
ln -s $DIR/git/.gitconfig $HOME/.gitconfig
ln -s $DIR/tmux/.tmux.conf $HOME/.tmux.conf
ln -s $DIR/zsh/.zshrc $HOME/.zshrc
ln -s $DIR/zsh/.zsh $HOME/.zsh
ln -s $DIR/zsh/t $HOME/.local/bin/t
ln -s $DIR/zsh/tt $HOME/.local/bin/tt
ln -s $DIR/zsh/tt $HOME/.local/bin/gbt
ln -s $DIR/starship/starship.toml $HOME/.config/starship.toml
ln -s $DIR/nvim $HOME/.config/nvim
