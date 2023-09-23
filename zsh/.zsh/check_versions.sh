#!/bin/bash

function run_check() {
  local red="\e[31m"
  local green="\e[32m"
  local yellow="\e[33m"
  local blue="\e[34m"
  local grey="\e[90m"
  local reset="\e[0m"

  if [[ $2 != $3 ]]; then
    echo -e "❌ $yellow$1$reset: $yellow$2$reset -> $blue$3 ($4)$reset - $grey$5$reset"
  else
    echo -e "✅ $green$1$reset: $grey$2 ($4)$reset"
  fi
}

function api() {
  url=$(echo "$1" | sed "s#://#://api.#" | sed "s#github\.com#github.com/repos#")
  filter="map({tag_name, published_at}) | map(select(.tag_name | test(\""$2"\")))[0]"
  echo $(curl -s "$url" | jq -r "$filter")
}

function version() {
  echo $(echo "$1" | jq -r '.tag_name')
}

function date() {
  echo $(echo "$1" | jq -r '.published_at | sub("T.*$"; "")')
}

echo "Checking software is up to date..."

# Rust
url="https://github.com/rust-lang/rust/releases"
details=$(api "$url" "^[0-9]")
latest=$(version "$details")
latest_date=$(date "$details")
installed=$(rustc --version | rg "^rustc" | sed "s/^rustc //" | sed "s/ ([0-9a-f]\+ [0-9\-]\+)$//")
run_check "Rust" $installed $latest $latest_date $url

# Neovim
url="https://github.com/neovim/neovim/releases"
details=$(api "$url" "^v[0-9]")
latest=$(version "$details")
latest_date=$(date "$details")
installed=$(nvim --version | rg "^NVIM v" | sed "s/^NVIM //")
run_check "Neovim" $installed $latest $latest_date $url

# Starship
url="https://github.com/starship/starship/releases"
details=$(api "$url" "^v[0-9]")
latest=$(version "$details")
latest_date=$(date "$details")
installed=$(starship --version | rg "^starship" | sed "s/^starship /v/")
run_check "Starship" $installed $latest $latest_date $url

# tmux
url="https://github.com/tmux/tmux/releases"
details=$(api "$url" "^[0-9]")
latest=$(version "$details")
latest_date=$(date "$details")
installed=$(tmux -V | rg "^tmux" | sed "s/^tmux //")
run_check "tmux" $installed $latest $latest_date $url

# Ripgrep
url="https://github.com/BurntSushi/ripgrep/releases"
details=$(api "$url" "^[0-9]")
latest=$(version "$details")
latest_date=$(date "$details")
installed=$(rg --version | rg "^ripgrep " | sed "s/^ripgrep //" | sed "s/ (rev .*)//")
run_check "Ripgrep" $installed $latest $latest_date $url

# fd
url="https://github.com/sharkdp/fd/releases"
details=$(api "$url" "^v[0-9]")
latest=$(version "$details")
latest_date=$(date "$details")
installed=$(fd --version | rg "^fd " | sed "s/^fd /v/")
run_check "fd" $installed $latest $latest_date $url

# eza
url="https://github.com/eza-community/eza/releases"
details=$(api "$url" "^v[0-9]")
latest=$(version "$details")
latest_date=$(date "$details")
installed=$(eza --version | rg "^v[0-9]" | sed "s/ \[+git\]//")
run_check "eza" $installed $latest $latest_date $url

# delta
url="https://github.com/dandavison/delta/releases"
details=$(api "$url" "^[0-9]")
latest=$(version "$details")
latest_date=$(date "$details")
installed=$(delta --version | rg "^delta [0-9]" | sed "s/^delta //")
run_check "delta" $installed $latest $latest_date $url

# fzf
url="https://github.com/junegunn/fzf/releases"
details=$(api "$url" "^[0-9]")
latest=$(version "$details")
latest_date=$(date "$details")
installed=$(fzf --version | rg "^[0-9]" | sed "s/ ([0-9a-f]\+)$//")
run_check "fzf" $installed $latest $latest_date $url

# zoxide
url="https://github.com/ajeetdsouza/zoxide/releases"
details=$(api "$url" "^v[0-9]")
latest=$(version "$details")
latest_date=$(date "$details")
installed=$(zoxide --version | rg "^zoxide [0-9]" | sed "s/^zoxide /v/")
run_check "zoxide" $installed $latest $latest_date $url

# bat
url="https://github.com/sharkdp/bat/releases"
details=$(api "$url" "^v[0-9]")
latest=$(version "$details")
latest_date=$(date "$details")
installed=$(bat --version | rg "^bat [0-9]" | sed "s/^bat /v/" | sed "s/ ([0-9a-f]\+)$//")
run_check "bat" $installed $latest $latest_date $url
