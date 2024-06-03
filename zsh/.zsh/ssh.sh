#!/bin/bash

function is_agent_running {
  # Check if SSH_AGENT_PID environment variable is set
  if [[ -z "$SSH_AGENT_PID" ]]; then
      return 1
  fi

  # Check if the process with SSH_AGENT_PID is running
  if ps -p $SSH_AGENT_PID > /dev/null; then
      return 0
  else
      return 1
  fi
}

if [[ ! is_agent_running ]]; then
  echo "SSH agent not running. Starting..."
  eval $(ssh-agent -s)
  ssh-add
fi

