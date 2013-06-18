#!/usr/bin/env bash

check_for_binstubs()
{
  local root
  local potential_path
  if [ "$1" ]; then
    root="$1"
  else
    root="$PWD"
  fi
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

check_for_bundles ()
{
  # go through the list of bundles and run make_shims
  if [ -f "${RBENV_ROOT}/bundles" ]; then
    IFS=$'\n'
    bundles="$(sort -u ${RBENV_ROOT}/bundles)"
    unset IFS
    for bundle in $bundles; do
      check_for_binstubs "$bundle"
      for shim in $RBENV_COMMAND_PATH/*; do
        register_shim "${shim##*/}"
      done
    done
    unset IFS
  fi
}

add_to_bundles ()
{
  local root
  local potential_path
  if [ "$1" ]; then
    root="$1"
  else
    root="$PWD"
  fi

  # add the given path to the list of bundles
  echo "$root" >> ${RBENV_ROOT}/bundles

  # update the list of bundles to remove any stale ones
  IFS=$'\n';
  bundles=$(sort -u ${RBENV_ROOT}/bundles)
  rm ${RBENV_ROOT}/bundles
  for bundle in $bundles; do
    if [ -f "$bundle/Gemfile" ]; then
      echo "$bundle" >> ${RBENV_ROOT}/bundles
    fi
  done
}

if [ -z "$DISABLE_BINSTUBS" ]; then
  add_to_bundles
  check_for_bundles
fi

