#!/usr/bin/env bats

load test_helper

@test "help for env is available" {
  run rbenv-help 'bundles'
  assert_success
  assert_line "Usage: rbenv bundles"
  assert_line "Shows bundle path and associated binstub directory (if present)"
}

