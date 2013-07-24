#!/usr/bin/env bats

load test_helper

@test "finds plugin which hook" {
  run rbenv-hooks which
  assert_success
  assert_output "$RBENV_HOOK_PATH/which/rbenv-binstubs.bash"
}

@test "finds plugin rehash hook" {
  run rbenv-hooks rehash
  assert_success
  assert_output "$RBENV_HOOK_PATH/rehash/rbenv-binstubs.bash"
}
