#!/usr/bin/env bash

add_to_bundles ()
{
  local root
  if [ "$1" ]; then
    root="$1"
  else
    root="$PWD"
  fi

  # update the list of bundles to remove any stale ones
  local new_bundle
  new_bundle=true
  new_bundles=${RBENV_ROOT}/bundles.new.$$
  : > $new_bundles
  if [ -s ${RBENV_ROOT}/bundles ]; then
    OLDIFS="${IFS-$' \t\n'}"
    IFS=$'\n' bundles=(`cat ${RBENV_ROOT}/bundles`)
    IFS="$OLDIFS"
    for bundle in "${bundles[@]}"; do
      if [ "X$bundle" = "X$root" ]; then
        new_bundle=false
      fi
      if [ -f "$bundle/Gemfile" ]; then
        echo "$bundle" >> $new_bundles
      fi
    done
  fi
  if [ "$new_bundle" = "true" ]; then
    # add the given path to the list of bundles
    if [ -f "$root/Gemfile" ]; then
      echo "$root" >> $new_bundles
    fi
  fi
  mv -f $new_bundles ${RBENV_ROOT}/bundles
}

if [ -z "$DISABLE_BINSTUBS" -a "X$1" = "Xbundle" ]; then
  add_to_bundles
fi

