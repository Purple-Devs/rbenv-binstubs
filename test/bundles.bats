#!/usr/bin/env bats

load test_helper

@test "running rbenv-bundles lists the project directory" {

  create_Gemfile
  create_binstub fred

  assert [ ! -e "${RBENV_ROOT}/bundles" ]

  (
  cd ${RAILS_ROOT}
  run rbenv-rehash
  assert_success ""
  )

  run rbenv-bundles
  assert_success
  assert_line "${RAILS_ROOT}: $BUNDLE_BIN"
}

@test "running rbenv-bundles lists multiple project directories" {

  create_Gemfile .1
  create_Gemfile .2
  create_binstub fred .1
  create_binstub john .2

  assert [ ! -e "${RBENV_ROOT}/bundles" ]

  (
  cd ${RAILS_ROOT}.1
  run rbenv-rehash
  assert_success ""
  )
  (
  cd ${RAILS_ROOT}.2
  run rbenv-rehash
  assert_success ""
  )

  run rbenv-bundles
  assert_success
  assert_line "${RAILS_ROOT}.1: $BUNDLE_BIN"
  assert_line "${RAILS_ROOT}.2: $BUNDLE_BIN"
}
