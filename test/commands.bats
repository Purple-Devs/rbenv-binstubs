#!/usr/bin/env bats

load test_helper

@test "bundles is listed in rbenv commands" {
  run rbenv-commands
  assert_success
  assert_line "bundles"
}

@test "commands --sh should not list bundles" {
  run rbenv-commands --sh
  assert_success
  refute_line "bundles"
}

@test "commands --no-sh should list bundles" {
  run rbenv-commands --no-sh
  assert_success
  assert_line "bundles"
}
