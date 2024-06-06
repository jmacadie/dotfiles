#!/bin/bash

ps -ef | grep -v grep | grep ssh-agent | grep $(whoami | head -c 8) > /dev/null
if [[ $? == 1 ]]; then
  echo "SSH agent not running. Starting..."
  eval $(ssh-agent -s)
  ssh-add
fi

