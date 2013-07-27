#!/usr/bin/env bash

check_for_binstubs()
{
  local root
  local potential_path
  root="$PWD"
  while [ -n "$root" ]; do
    if [ -f "$root/Gemfile" ]; then
      if [ -n "$BUNDLE_BIN" ]; then
        case "$BUNDLE_BIN" in
        /*)
            potential_path="$BUNDLE_BIN/$RBENV_COMMAND"
            ;;
        ?*)
            potential_path="$root/$BUNDLE_BIN/$RBENV_COMMAND"
            ;;
        esac
      else
        potential_path="$root/bin/$RBENV_COMMAND"
        if [ -f "$HOME/.bundle/config" ]; then
          while read key value 
          do
            case "$key" in
            'BUNDLE_BIN:')
                case "$value" in
                /*)
                    potential_path="$value/$RBENV_COMMAND"
                    ;;
                ?*)
                    potential_path="$root/$value/$RBENV_COMMAND"
                    ;;
                esac
                break
                ;;
            esac
          done < "$HOME/.bundle/config"
        fi
      fi
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

