#!/bin/bash

function run_check() {
  if [[ $2 != $3 ]]; then
    echo -e
    echo "$1 is outdated!"
    echo "-------------------"
    echo "Installed version is $2"
    echo "Latest released version is $3, ($4)"
    echo "See: $5"
  fi
}

function api_url() {
  echo $1 | sed "s#://#://api.#" | sed "s#github\.com#github.com/repos#"
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
installed=$(fd --version | rg "^fd " | sed "s/^fd //")
run_check "fd" $installed $latest $latest_date $url

# eza
url="https://github.com/eza-community/eza/releases"
details=$(api "$url" "^v[0-9]")
latest=$(version "$details")
latest_date=$(date "$details")
installed=$(eza --version | rg "^v[0-9]" | sed "s/ [\+git]//")
run_check "eza" $installed $latest $latest_date $url
