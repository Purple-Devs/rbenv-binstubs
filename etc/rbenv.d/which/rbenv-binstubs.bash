#!/usr/bin/env bash

if [ -f Gemfile ] && [ -x "bin/$RBENV_COMMAND" ]; then
  RBENV_COMMAND_PATH="bin/$RBENV_COMMAND"
fi
