#!/usr/bin/env bash

register_binstubs()
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
        for shim in $potential_path/*; do
          register_shim "${shim##*/}"
        done
      fi
      break
    fi
    root="${root%/*}"
  done
}

register_bundles ()
{
  # go through the list of bundles and run make_shims
  if [ -f "${RBENV_ROOT}/bundles" ]; then
    IFS=$'\n'
    bundles="$(sort -u ${RBENV_ROOT}/bundles)"
    unset IFS
    for bundle in $bundles; do
      register_binstubs "$bundle"
    done
    unset IFS
  fi
}

add_to_bundles ()
{
  local root
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
  register_bundles
fi

