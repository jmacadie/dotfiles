##### PATH / ENV ###############################################################

# Ensure user binaries come first
export PATH="$HOME/.cargo/bin:$HOME/bin:$HOME/.local/bin:$PATH"

# Preferred editor
export EDITOR=nvim


##### HISTORY #################################################################

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY


##### COMPLETION ###############################################################

autoload -Uz compinit
compinit

# Better completion behaviour
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:git:*' user-commands ll:'Show limited log between branches'


##### KEYBINDINGS / VI MODE ####################################################

# Enable vi mode
bindkey -v

# Reduce ESC delay (important for vi mode)
export KEYTIMEOUT=1

# Optional: keep ^R incremental search
bindkey '^R' history-incremental-search-backward


##### PLUGINS ##################################################################

# zsh-autosuggestions
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Make autosuggestions subtle
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# zsh-syntax-highlighting
# MUST be sourced last
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


##### PROXY SETTINGS ###########################################################

export http_proxy="http://127.0.0.1:9000"
export https_proxy="$http_proxy"
export no_proxy="localhost,127.0.0.1"

##### PROMPT ###################################################################

eval "$(starship init zsh)"


##### OTHER PROGRAMS ###########################################################

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# bat
export BAT_THEME="base16"

# zoxide
eval "$(zoxide init zsh)"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# atuin
source "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"


##### PERSONAL SCRIPTS #########################################################

# Check if ssh agent is running & start it if not
source $HOME/.zsh/ssh.sh

# Run my check versions script
$HOME/.zsh/check_versions.sh


##### ALIASES ##################################################################

alias cd=z
alias cat=bat
alias ls=eza
alias ll="eza -la"
alias lt="eza -a --tree"
alias vim=nvim
alias update="sudo apt update && sudo apt upgrade -y --allow-downgrades && sudo apt autoremove -y"


##### MISC #####################################################################

# Make Ctrl+D not exit immediately
setopt IGNOREEOF

# Load local overrides if present
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
