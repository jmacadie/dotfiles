
if [ -f ~/.bash/.bash_aliases ]; then
	. ~/.bash/.bash_aliases
fi

if [ -f ~/.bash/.bash_prompt ]; then
	. ~/.bash/.bash_prompt
fi
. "$HOME/.cargo/env"
