#!/bin/bash

function ssh_agents {
  ps -ef \
    | grep -v grep \
    | grep ssh-agent \
    | grep $(whoami | head -c 8)
}

function is_agent_running {
  ssh_agents | grep "$1" > /dev/null
  # return $?
}

function any_agent {
  ssh_agents | head -n 1 | awk '{print $2}'
}

# SSH_AGENT_PID
if [[ ! -v SSH_AGENT_PID ]] || ! is_agent_running "$SSH_AGENT_PID"; then
  PID=$(any_agent)
  if [[ -n "$PID" ]]; then
    SSH_AGENT_PID="$PID"
    export SSH_AGENT_PID
  else
    eval $(ssh-agent -s)
  fi
fi

# SSH_AUTH_SOCK
SOCK_LINK=~/.ssh/ssh_auth_sock
if [[ -L "$SOCK_LINK" ]]; then
  # Have symlink
  SOCK=$(readlink "$SOCK_LINK")
  if [[ ! -S "$SOCK" ]]; then
    # Have symlink but it doesn't point to a socket
    rm "$SOCK_LINK"
    if [[ ! -v SSH_AUTH_SOCK || ! -S "$SSH_AUTH_SOCK" ]]; then
      # Have symlink but it doesn't point to a socket. We don't have SSH_AUTH_SOCK
      eval $(ssh-agent -s)
    fi
    ln -sf "$SSH_AUTH_SOCK" "$SOCK_LINK"
  fi
else
  # Don't have symlink
  if [[ ! -v SSH_AUTH_SOCK || ! -S "$SSH_AUTH_SOCK" ]]; then
    # Don't have symlink. We don't have SSH_AUTH_SOCK
    eval $(ssh-agent -s)
  fi
  ln -sf "$SSH_AUTH_SOCK" "$SOCK_LINK"
fi
SSH_AUTH_SOCK="$SOCK_LINK"
export SSH_AUTH_SOCK

# SSH keys added
if ! (ssh-add -l > /dev/null); then
    # No ssh keys have been added to your 'ssh-agent' since the last reboot. Adding default keys now
    ssh-add
fi

