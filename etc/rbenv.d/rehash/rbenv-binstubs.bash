#!/usr/bin/env bash

register_binstubs()
{
  local root
  local potential_path
  local global_bundle_config
  if [ "$1" ]; then
    root="$1"
  else
    root="$PWD"
  fi
  global_bundle_config=${BUNDLE_CONFIG:-$HOME/.bundle/config}
  while [ -n "$root" ]; do
    if [ -f "$root/Gemfile" ]; then
      if [ -n "$BUNDLE_BIN" ]; then
        case "$BUNDLE_BIN" in
        /*)
            potential_path="$BUNDLE_BIN"
            ;;
        ?*)
            potential_path="$root/$BUNDLE_BIN"
            ;;
        esac
      else
        potential_path="$root/bin"
        if [ -f "$global_bundle_config" ]; then
          while read key value 
          do
            case "$key" in
            'BUNDLE_BIN:')
                case "$value" in
                '"'/*)
                    potential_path="${value%'"'}"
                    potential_path="${potential_path#'"'}"
                    ;;
                '"'*)
                    potential_path="${value%'"'}"
                    potential_path="$root/${potential_path#'"'}"
                    ;;
                /*)
                    potential_path="$value"
                    ;;
                ?*)
                    potential_path="$root/$value"
                    ;;
                esac
                break
                ;;
            esac
          done < "$global_bundle_config"
        fi
      fi
      if [ -f "$root/.bundle/config" ]; then
	while read key value 
	do
	  case "$key" in
	  'BUNDLE_BIN:')
	      case "$value" in
              '"'/*)
                  potential_path="${value%'"'}"
                  potential_path="${potential_path#'"'}"
                  ;;
              '"'*)
                  potential_path="${value%'"'}"
                  potential_path="$root/${potential_path#'"'}"
                  ;;
	      /*)
		  potential_path="$value"
		  ;;
	      ?*)
		  potential_path="$root/$value"
		  ;;
	      esac
	      break
	      ;;
	  esac
	done < "$root/.bundle/config"
      fi
      if [ -d "$potential_path" ]; then
        for shim in "$potential_path"/*; do
          if [ -x "$shim" ]; then
            register_shim "${shim##*/}"
          fi
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
    OLDIFS="${IFS-$' \t\n'}"
    IFS=$'\n' bundles=(`cat ${RBENV_ROOT}/bundles`)
    IFS="$OLDIFS"
    for bundle in "${bundles[@]}"; do
      register_binstubs "$bundle"
    done
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

if [ -z "$DISABLE_BINSTUBS" ]; then
  add_to_bundles
  register_bundles
fi

