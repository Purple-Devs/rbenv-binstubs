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
        if [ -f "$HOME/.bundle/config" ]; then
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
          done < "$HOME/.bundle/config"
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
        for shim in $potential_path/*; do
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
  : > ${RBENV_ROOT}/bundles.new
  if [ -s ${RBENV_ROOT}/bundles ]; then
    OLDIFS="${IFS-$' \t\n'}"
    IFS=$'\n' bundles=(`cat ${RBENV_ROOT}/bundles`)
    IFS="$OLDIFS"
    for bundle in "${bundles[@]}"; do
      if [ "X$bundle" = "X$root" ]; then
        new_bundle=false
      fi
      if [ -f "$bundle/Gemfile" ]; then
        echo "$bundle" >> ${RBENV_ROOT}/bundles.new
      fi
    done
  fi
  if [ "$new_bundle" = "true" ]; then
    # add the given path to the list of bundles
    if [ -f "$root/Gemfile" ]; then
      echo "$root" >> ${RBENV_ROOT}/bundles.new
    fi
  fi
  mv -f ${RBENV_ROOT}/bundles.new ${RBENV_ROOT}/bundles
}

if [ -z "$DISABLE_BINSTUBS" ]; then
  add_to_bundles
  register_bundles
fi

