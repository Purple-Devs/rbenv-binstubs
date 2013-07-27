#!/usr/bin/env bats

load test_helper

@test "running rbenv-bundles lists the project directory for project specific config" {

  create_Gemfile
  create_bundle_config
  create_binstub fred

  assert [ ! -e "${RBENV_ROOT}/bundles" ]

  (
  cd ${RAILS_ROOT}
  run rbenv-rehash
  assert_success ""
  )

  run rbenv-bundles
  assert_success
  assert_line "${RAILS_ROOT}: $TEST_BUNDLE_BIN"
}

@test "running rbenv-bundles lists the project directory for global config" {

  create_Gemfile
  create_global_bundle_config
  create_binstub fred

  assert [ ! -e "${RBENV_ROOT}/bundles" ]

  (
  cd ${RAILS_ROOT}
  run rbenv-rehash
  assert_success ""
  )

  run rbenv-bundles
  assert_success
  assert_line "${RAILS_ROOT}: $TEST_BUNDLE_BIN"
}

@test "running rbenv-bundles lists the project directory for env set config" {

  create_Gemfile
  set_bundle_config_env
  create_binstub fred

  assert [ ! -e "${RBENV_ROOT}/bundles" ]

  (
  cd ${RAILS_ROOT}
  BUNDLE_BIN=$TEST_BUNDLE_BIN run rbenv-rehash
  assert_success ""
  )

  BUNDLE_BIN=$TEST_BUNDLE_BIN run rbenv-bundles
  assert_success
  assert_line "${RAILS_ROOT}: $TEST_BUNDLE_BIN"
}

@test "running rbenv-bundles lists multiple project directories" {

  create_Gemfile .1
  create_bundle_config .1
  create_binstub fred .1
  (
  cd ${RAILS_ROOT}.1
  run rbenv-rehash
  assert_success ""
  )

  create_Gemfile .2
  create_bundle_config .2
  create_binstub john .2
  (
  cd ${RAILS_ROOT}.2
  run rbenv-rehash
  assert_success ""
  )

  run rbenv-bundles
  assert_success 
  assert_line "${RAILS_ROOT}.1: $TEST_BUNDLE_BIN"
  assert_line "${RAILS_ROOT}.2: $TEST_BUNDLE_BIN"
}
