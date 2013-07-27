#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${RBENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  cat > "${bin}/$2" <<!
#!/usr/bin/env bash
echo output from ${1}/${2}
!

  chmod +x "${bin}/$2"
}

@test "remembers where bundle was called once" {
  create_Gemfile
  create_executable 1.8 bundle

  assert [ ! -e "${RBENV_ROOT}/bundles" ]

  (
  cd ${RAILS_ROOT}
  RBENV_VERSION=1.8 run rbenv-exec bundle
  assert_success "output from 1.8/bundle"
  )
  assert [ -e "${RBENV_ROOT}/bundles" ]
  run cat "${RBENV_ROOT}/bundles"
  assert_success "${RAILS_ROOT}"

}

@test "remembers where bundle was called both times" {
  create_Gemfile .1
  create_Gemfile .2
  create_executable 1.8 bundle

  assert [ ! -e "${RBENV_ROOT}/bundles" ]

  (
  cd ${RAILS_ROOT}.1
  RBENV_VERSION=1.8 run rbenv-exec bundle
  assert_success "output from 1.8/bundle"
  )
  assert [ -e "${RBENV_ROOT}/bundles" ]
  run cat "${RBENV_ROOT}/bundles"
  assert_success "${RAILS_ROOT}.1"

  (
  cd ${RAILS_ROOT}.2
  RBENV_VERSION=1.8 run rbenv-exec bundle
  assert_success "output from 1.8/bundle"
  )
  run cat "${RBENV_ROOT}/bundles"
  assert_success 
  assert_line "${RAILS_ROOT}.1"
  assert_line "${RAILS_ROOT}.2"

}
