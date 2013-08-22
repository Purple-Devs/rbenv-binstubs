unset RBENV_VERSION
unset RBENV_DIR

RBENV_TEST_DIR="${BATS_TMPDIR}/rbenv"
RAILS_ROOT="${RBENV_TEST_DIR}/railsapp"
PLUGIN="${RBENV_TEST_DIR}/root/plugins/rbenv-binstubs"

TEST_BUNDLE_BIN=.bundle/bin

# guard against executing this block twice due to bats internals
if [ "$RBENV_ROOT" != "${RBENV_TEST_DIR}/root" ]; then
  export RBENV_ROOT="${RBENV_TEST_DIR}/root"
  export HOME="${RBENV_TEST_DIR}/home"
  local parent
  # this differs if the tests is being run individually or as a suite
  parent="${BATS_TEST_DIRNAME%/.}"
  parent="${parent%${parent##*/}}"
  export RBENV_HOOK_PATH="${parent}etc/rbenv.d"

  PATH=/usr/bin:/bin:/usr/sbin:/sbin
  PATH="${RBENV_TEST_DIR}/bin:$PATH"
  PATH="${BATS_TEST_DIRNAME}/../bin:$PATH"
  PATH="${BATS_TEST_DIRNAME}/../rbenv/libexec:$PATH"
  PATH="${BATS_TEST_DIRNAME}/../rbenv/test/libexec:$PATH"
  PATH="${RBENV_ROOT}/shims:$PATH"
  export PATH
fi

# create_binstubs command [rails_root_suffix]
create_binstub() {
  mkdir -p "$RAILS_ROOT$2/$TEST_BUNDLE_BIN"
  touch "$RAILS_ROOT$2/$TEST_BUNDLE_BIN/$1"
  chmod +x "$RAILS_ROOT$2/$TEST_BUNDLE_BIN/$1"
}

# create_bundle_config [rails_root_suffix [quote_char]]
create_bundle_config() {
  mkdir -p "$RAILS_ROOT$1/.bundle"
  cat > "$RAILS_ROOT$1/.bundle/config" <<!
--- 
BUNDLE_BIN: $2$TEST_BUNDLE_BIN$2
!
}

set_bundle_config_env() {
export BUNDLE_BIN=$TEST_BUNDLE_BIN
}

# create_global_bundle_config [quote_char]
create_global_bundle_config() {
  mkdir -p "$HOME/.bundle"
  cat > "$HOME/.bundle/config" <<!
--- 
BUNDLE_BIN: $1${TEST_BUNDLE_BIN}$1
!
}

delete_binstub() {
  rm -f "$RAILS_ROOT$2/$TEST_BUNDLE_BIN/$1"
}

# create_Gemfile [rails_root_suffix]
create_Gemfile() {
  mkdir -p "$RAILS_ROOT$1"
  touch "$RAILS_ROOT$1/Gemfile"
}

teardown() {
  rm -rf "$RBENV_TEST_DIR"
}

flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed "s:${RBENV_TEST_DIR}:TEST_DIR:g" >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    flunk "expected failed exit status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_output() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
  else expected="$1"
  fi
  assert_equal "$expected" "$output"
}

assert_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    assert_equal "$2" "${lines[$1]}"
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then return 0; fi
    done
    flunk "expected line \`$1'"
  fi
}

refute_line() {
  if [ "$1" -ge 0 ] 2>/dev/null; then
    local num_lines="${#lines[@]}"
    if [ "$1" -lt "$num_lines" ]; then
      flunk "output has $num_lines lines"
    fi
  else
    local line
    for line in "${lines[@]}"; do
      if [ "$line" = "$1" ]; then
        flunk "expected to not find line \`$line'"
      fi
    done
  fi
}

assert() {
  if ! "$@"; then
    flunk "failed: $@"
  fi
}
