#!/usr/bin/env bash

check_for_binstubs()
{
  local root
  local potential_path
  root="$PWD"
  while [ -n "$root" ]; do
    if [ -f "$root/Gemfile" ]; then
      potential_path="$root/bin/$RBENV_COMMAND"
      if [ -f "$root/.bundle/config" ]; then
	while read key value 
	do
	  case "$key" in
	  'BUNDLE_BIN:')
	      case "$value" in
	      /*)
		  potential_path="$value/$RBENV_COMMAND"
		  ;;
	      *)
		  potential_path="$root/$value/$RBENV_COMMAND"
		  ;;
	      esac
	      break
	      ;;
	  esac
	done < "$root/.bundle/config"
      fi
      if [ -x "$potential_path" ]; then
	RBENV_COMMAND_PATH="$potential_path"
      fi
      break
    fi
    root="${root%/*}"
  done
}

if [ -z "$DISABLE_BINSTUBS" ]; then
  check_for_binstubs
fi

