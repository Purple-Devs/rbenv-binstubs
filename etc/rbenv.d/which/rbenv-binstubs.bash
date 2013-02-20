#!/usr/bin/env bash

check_for_binstubs()
{
  local root
  root="$PWD"
  while [ -n "$root" ]; do
    if [ -e "$root/Gemfile" ]; then
      if [ -x "$root/bin/$RBENV_COMMAND" ]; then
	RBENV_COMMAND_PATH="$root/bin/$RBENV_COMMAND"
      fi
      root=""
    fi
    root="${root%/*}"
  done
}

if [ -z "$DISABLE_BINSTUBS" ]; then
  check_for_binstubs
fi

