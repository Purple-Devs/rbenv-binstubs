#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${RBENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "remembers where rehash was called once with project specific config" {
  create_Gemfile

  assert [ ! -e "${RBENV_ROOT}/bundles" ]

  (
  cd ${RAILS_ROOT}
  run rbenv-rehash
  assert_success ""
  )
  assert [ -e "${RBENV_ROOT}/bundles" ]
  run cat "${RBENV_ROOT}/bundles"
  assert_success "${RAILS_ROOT}"

}

@test "remembers where rehash was called from multiple projects" {
  create_Gemfile .1

  assert [ ! -e "${RBENV_ROOT}/bundles" ]

  (
  cd ${RAILS_ROOT}.1
  run rbenv-rehash
  assert_success ""
  )
  assert [ -e "${RBENV_ROOT}/bundles" ]
  run cat "${RBENV_ROOT}/bundles"
  assert_success "${RAILS_ROOT}.1"

  create_Gemfile .2
  (
  cd ${RAILS_ROOT}.2
  run rbenv-rehash
  assert_success ""
  )
  assert [ -e "${RBENV_ROOT}/bundles" ]
  run cat "${RBENV_ROOT}/bundles"
  assert_success
  assert_line "${RAILS_ROOT}.1"
  assert_line "${RAILS_ROOT}.2"
}


@test "rehash handles global BUNDLE_BIN settings" {

  create_Gemfile
  create_global_bundle_config
  create_binstub fred
  (
  cd ${RAILS_ROOT}
  run rbenv-rehash
  assert_success ""
  )

  run rbenv-bundles
  assert_success
  assert_line "${RAILS_ROOT}: $TEST_BUNDLE_BIN"
  assert [ -e "${RBENV_ROOT}/shims/fred" ]
}

@test "rehash handles env BUNDLE_BIN settings" {

  create_Gemfile
  create_binstub fred
  (
  cd ${RAILS_ROOT}
  BUNDLE_BIN=$TEST_BUNDLE_BIN run rbenv-rehash
  assert_success ""
  )

  BUNDLE_BIN=$TEST_BUNDLE_BIN run rbenv-bundles
  assert_success
  assert_line "${RAILS_ROOT}: $TEST_BUNDLE_BIN"
  assert [ -e "${RBENV_ROOT}/shims/fred" ]
}

@test "rehash handles mix of local and global settings" {

  create_Gemfile .1
  create_bundle_config .1
  create_binstub fred .1
  (
  cd ${RAILS_ROOT}.1
  run rbenv-rehash
  assert_success ""
  )

  create_Gemfile .2
  TEST_BUNDLE_BIN=bin2 create_global_bundle_config
  TEST_BUNDLE_BIN=bin2 create_binstub john .2
  (
  cd ${RAILS_ROOT}.2
  run rbenv-rehash
  assert_success ""
  )

  create_Gemfile .4
  TEST_BUNDLE_BIN=bin4 create_bundle_config .4
  TEST_BUNDLE_BIN=bin4 create_binstub paul .4
  (
  cd ${RAILS_ROOT}.4
  # has to include global env as it rechecks all binstub dirs
  run rbenv-rehash
  assert_success ""
  )

  run rbenv-bundles
  assert_success
  assert_line "${RAILS_ROOT}.1: $TEST_BUNDLE_BIN"
  assert_line "${RAILS_ROOT}.2: bin2"
  assert_line "${RAILS_ROOT}.4: bin4"

  assert [ -e "${RBENV_ROOT}/shims/fred" ]
  assert [ -e "${RBENV_ROOT}/shims/john" ]
  assert [ -e "${RBENV_ROOT}/shims/paul" ]
}


@test "rehash handles mix of local and environment BUNDLE_BIN settings" {

  create_Gemfile .1
  create_bundle_config .1
  create_binstub fred .1
  (
  cd ${RAILS_ROOT}.1
  run rbenv-rehash
  assert_success ""
  )

  create_Gemfile .3
  TEST_BUNDLE_BIN=bin3 create_binstub mary .3
  (
  cd ${RAILS_ROOT}.3
  run env BUNDLE_BIN=bin3 rbenv-rehash
  assert_success ""
  )

  create_Gemfile .4
  TEST_BUNDLE_BIN=bin4 create_bundle_config .4
  TEST_BUNDLE_BIN=bin4 create_binstub paul .4
  (
  cd ${RAILS_ROOT}.4
  # has to include global env as it rechecks all binstub dirs
  run env BUNDLE_BIN=bin3 rbenv-rehash
  assert_success ""
  )

  run env BUNDLE_BIN=bin3 rbenv-bundles
  assert_success
  assert_line "${RAILS_ROOT}.1: $TEST_BUNDLE_BIN"
  assert_line "${RAILS_ROOT}.3: bin3"
  assert_line "${RAILS_ROOT}.4: bin4"

  assert [ -e "${RBENV_ROOT}/shims/fred" ]
  assert [ -e "${RBENV_ROOT}/shims/paul" ]
  assert [ -e "${RBENV_ROOT}/shims/mary" ]
}


@test "creates shims for binstubs from one railsapp" {
  create_Gemfile
  create_bundle_config
  create_binstub "jimmy"
  create_binstub "hello"

  assert [ ! -e "${RBENV_ROOT}/shims/hello" ]
  assert [ ! -e "${RBENV_ROOT}/shims/jimmy" ]

  (
  cd $RAILS_ROOT
  run rbenv-rehash
  assert_success ""
  )

  run ls "${RBENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
hello
jimmy
OUT

}

@test "creates shims for binstubs from multiple railsapps" {
  create_Gemfile .1
  create_bundle_config .1
  create_binstub "jimmy" .1

  (
  cd ${RAILS_ROOT}.1
  run rbenv-rehash
  assert_success ""
  )

  assert [ -e "${RBENV_ROOT}/shims/jimmy" ]

  create_Gemfile .2
  create_bundle_config .2
  create_binstub "hello" .2
  (
  cd ${RAILS_ROOT}.2
  run rbenv-rehash
  assert_success ""
  )
  assert [ -e "${RBENV_ROOT}/shims/hello" ]

  run ls "${RBENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
hello
jimmy
OUT

}

@test "removes shims and forgets railsapp if Gemfile is removed" {
  create_Gemfile
  create_bundle_config
  create_binstub "fred"

  (
  cd $RAILS_ROOT
  run rbenv-rehash
  assert_success ""
  )

  assert [ -e "${RBENV_ROOT}/shims/fred" ]

  (
  cd $RAILS_ROOT
  rm -f Gemfile

  run rbenv-rehash
  assert_success ""
  )

  assert [ ! -e "${RBENV_ROOT}/shims/fred" ]

  run cat "${RBENV_ROOT}/bundles"
  assert_success ""

}


@test "removes shim if binstub is removed" {
  create_Gemfile
  create_bundle_config
  create_binstub "fred"

  (
  cd ${RAILS_ROOT}
  run rbenv-rehash
  assert_success ""
  )

  assert [ -s "${RBENV_ROOT}/bundles" ]
  run cat "${RBENV_ROOT}/bundles"
  assert_success "${RAILS_ROOT}"

  assert [ -e "${RBENV_ROOT}/shims/fred" ]

  (
  cd ${RAILS_ROOT}
  delete_binstub 'fred'
  run rbenv-rehash
  assert_success ""
  )

  assert [ ! -e "${RBENV_ROOT}/shims/fred" ]
}


@test "removes shims if binstubs is removed from another project" {
  create_Gemfile .1
  create_bundle_config .1
  create_binstub "fred" .1

  (
  cd ${RAILS_ROOT}.1
  run rbenv-rehash
  assert_success ""
  )

  create_Gemfile .2
  create_bundle_config .2
  create_binstub "john" .2

  (
  cd ${RAILS_ROOT}.2
  run rbenv-rehash
  assert_success ""
  )

  assert [ -e "${RBENV_ROOT}/shims/fred" ]
  assert [ -e "${RBENV_ROOT}/shims/john" ]

  delete_binstub "fred" .1

  (
  cd ${RAILS_ROOT}.1
  run rbenv-rehash
  assert_success ""
  )

  assert [ ! -e "${RBENV_ROOT}/shims/fred" ]
  assert [ -e "${RBENV_ROOT}/shims/john" ]
}


# Standard tests

@test "empty rehash" {
  assert [ ! -d "${RBENV_ROOT}/shims" ]
  run rbenv-rehash
  assert_success ""
  assert [ -d "${RBENV_ROOT}/shims" ]
  rmdir "${RBENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${RBENV_ROOT}/shims"
  chmod -w "${RBENV_ROOT}/shims"
  run rbenv-rehash
  assert_failure "rbenv: cannot rehash: ${RBENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  mkdir -p "${RBENV_ROOT}/shims"
  touch "${RBENV_ROOT}/shims/.rbenv-shim"
  run rbenv-rehash
  assert_failure "rbenv: cannot rehash: ${RBENV_ROOT}/shims/.rbenv-shim exists"
}

@test "creates shims" {
  create_executable "1.8" "ruby"
  create_executable "1.8" "rake"
  create_executable "2.0" "ruby"
  create_executable "2.0" "rspec"

  assert [ ! -e "${RBENV_ROOT}/shims/ruby" ]
  assert [ ! -e "${RBENV_ROOT}/shims/rake" ]
  assert [ ! -e "${RBENV_ROOT}/shims/rspec" ]

  run rbenv-rehash
  assert_success ""

  run ls "${RBENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
rake
rspec
ruby
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${RBENV_TEST_DIR}/rbenv.d"
  mkdir -p "${hook_path}/rehash"
  cat > "${hook_path}/rehash/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  RBENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run rbenv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

