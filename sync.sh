#!/bin/bash

# Delete current files in the repo
rm -rf zsh/*
rm -rf tmux/*
rm -rf git/*
rm -rf starhip/*
rm -rf nvim/*

# Copy actual configs into repo
cp ~/.gitconfig git/

cp ~/.config/starship.toml starship/

cp -r ~/.config/nvim ./

cp ~/.tmux.conf tmux/

cp ~/.zshrc zsh/
cp ~/.bashrc zsh/
cp -r ~/.bash/ zsh/
