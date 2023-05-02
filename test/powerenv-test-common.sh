# Test script for Bourne-shell extensions. Set TARGET_SHELL
# to the shell to be tested (bash, zsh, etc) before sourcing it.
if [[ -z "$TARGET_SHELL" ]]; then
  echo "TARGET_SHELL variable not set"
  exit 1
fi

set -e

cd "$(dirname "$0")"
TEST_DIR=$PWD
export XDG_CONFIG_HOME=${TEST_DIR}/config
export XDG_DATA_HOME=${TEST_DIR}/data
PATH=$(dirname "$TEST_DIR"):$PATH
export PATH

# Reset the powerenv loading if any
export powerenv_CONFIG=$PWD
unset powerenv_BASH
unset powerenv_DIR
unset powerenv_FILE
unset powerenv_WATCHES
unset powerenv_DIFF

mkdir -p "${XDG_CONFIG_HOME}/powerenv"
touch "${XDG_CONFIG_HOME}/powerenv/powerenvrc"

has() {
  type -P "$1" &>/dev/null
}

powerenv_eval() {
  eval "$(powerenv export "$TARGET_SHELL")"
}

test_start() {
  cd "$TEST_DIR/scenarios/$1"
  powerenv allow
  if [[ "$powerenv_DEBUG" == "1" ]]; then
    echo
  fi
  echo "## Testing $1 ##"
  if [[ "$powerenv_DEBUG" == "1" ]]; then
    echo
  fi
}

test_stop() {
  rm -f "${XDG_CONFIG_HOME}/powerenv/powerenv.toml"
  cd /
  powerenv_eval
}

test_eq() {
  if [[ "$1" != "$2" ]]; then
    echo "FAILED: '$1' == '$2'"
    exit 1
  fi
}

test_neq() {
  if [[ "$1" == "$2" ]]; then
    echo "FAILED: '$1' != '$2'"
    exit 1
  fi
}

### RUN ###

powerenv allow || true
powerenv_eval

test_start base
  echo "Setting up"
  powerenv_eval
  test_eq "$HELLO" "world"

  WATCHES=$powerenv_WATCHES

  echo "Reloading (should be no-op)"
  powerenv_eval
  test_eq "$WATCHES" "$powerenv_WATCHES"

  sleep 1

  echo "Updating envrc and reloading (should reload)"
  touch .envrc
  powerenv_eval
  test_neq "$WATCHES" "$powerenv_WATCHES"

  echo "Leaving dir (should clear env set by dir's envrc)"
  cd ..
  powerenv_eval
  echo "${HELLO}"
  test -z "${HELLO}"

  unset WATCHES
test_stop

test_start inherit
  cp ../base/.envrc ../inherited/.envrc
  powerenv_eval
  echo "HELLO should be world:" "$HELLO"

  sleep 1
  echo "export HELLO=goodbye" > ../inherited/.envrc
  powerenv_eval
  test_eq "$HELLO" "goodbye"
test_stop

if has ruby; then
  test_start "ruby-layout"
    powerenv_eval
    test_neq "$GEM_HOME" ""
  test_stop
fi

# Make sure directories with spaces are fine
test_start "space dir"
  powerenv_eval
  test_eq "$SPACE_DIR" "true"
test_stop

test_start "child-env"
  powerenv_eval
  test_eq "$PARENT_PRE" "1"
  test_eq "$CHILD" "1"
  test_eq "$PARENT_POST" "1"
  test -z "$REMOVE_ME"
test_stop

test_start "special-vars"
  export powerenv_BASH=$(command -v bash)
  export powerenv_CONFIG=foobar
  powerenv_eval || true
  test -n "$powerenv_BASH"
  test_eq "$powerenv_CONFIG" "foobar"
  unset powerenv_BASH
  unset powerenv_CONFIG
test_stop

test_start "dump"
  powerenv_eval
  test_eq "$LS_COLORS" "*.ogg=38;5;45:*.wav=38;5;45"
  test_eq "$THREE_BACKSLASHES" '\\\'
  test_eq "$LESSOPEN" "||/usr/bin/lesspipe.sh %s"
test_stop

test_start "empty-var"
  powerenv_eval
  test_neq "${FOO-unset}" "unset"
  test_eq "${FOO}" ""
test_stop

test_start "empty-var-unset"
  export FOO=""
  powerenv_eval
  test_eq "${FOO-unset}" "unset"
  unset FOO
test_stop

test_start "in-envrc"
  powerenv_eval
  set +e
  ./test-in-envrc
  es=$?
  set -e
  test_eq "$es" "1"
test_stop

test_start "missing-file-source-env"
  powerenv_eval
test_stop

test_start "symlink-changed"
  # when using a symlink, reload if the symlink changes, or if the
  # target file changes.
  ln -fs ./state-A ./symlink
  powerenv_eval
  test_eq "${STATE}" "A"
  sleep 1

  ln -fs ./state-B ./symlink
  powerenv_eval
  test_eq "${STATE}" "B"
test_stop

test_start "symlink-dir"
  # we can allow and deny the target
  powerenv allow foo
  powerenv deny foo
  # we can allow and deny the symlink
  powerenv allow bar
  powerenv deny bar
test_stop

test_start "utf-8"
  powerenv_eval
  test_eq "${UTFSTUFF}" "♀♂"
test_stop

test_start "failure"
  # Test that powerenv_DIFF and powerenv_WATCHES are set even after a failure.
  #
  # This is needed so that powerenv doesn't go into a loop when the loading
  # fails.
  test_eq "${powerenv_DIFF:-}" ""
  test_eq "${powerenv_WATCHES:-}" ""

  powerenv_eval

  test_neq "${powerenv_DIFF:-}" ""
  test_neq "${powerenv_WATCHES:-}" ""
test_stop

test_start "watch-dir"
    echo "No watches by default"
    test_eq "${powerenv_WATCHES}" "${WATCHES}"

    powerenv_eval

    if ! powerenv show_dump "${powerenv_WATCHES}" | grep -q "testfile"; then
        echo "FAILED: testfile not added to powerenv_WATCHES"
        exit 1
    fi

    echo "After eval, watches have changed"
    test_neq "${powerenv_WATCHES}" "${WATCHES}"
test_stop

test_start "load-envrc-before-env"
  powerenv_eval
  test_eq "${HELLO}" "bar"
test_stop

test_start "load-env"
  echo "[global]
load_dotenv = true" > "${XDG_CONFIG_HOME}/powerenv/powerenv.toml"
  powerenv allow
  powerenv_eval
  test_eq "${HELLO}" "world"
test_stop

test_start "skip-env"
  powerenv_eval
  test -z "${SKIPPED}"
test_stop

if has python; then
  test_start "python-layout"
    rm -rf .powerenv

    powerenv_eval
    test -n "${VIRTUAL_ENV:-}"

    if [[ ":$PATH:" != *":${VIRTUAL_ENV}/bin:"* ]]; then
      echo "FAILED: VIRTUAL_ENV/bin not added to PATH"
      exit 1
    fi
  test_stop

  test_start "python-custom-virtual-env"
    powerenv_eval
    test "${VIRTUAL_ENV:-}" -ef ./foo

    if [[ ":$PATH:" != *":${PWD}/foo/bin:"* ]]; then
      echo "FAILED: VIRTUAL_ENV/bin not added to PATH"
      exit 1
    fi
  test_stop
fi

test_start "aliases"
  powerenv deny
  # check that allow/deny aliases work
  powerenv permit && powerenv_eval && test -n "${HELLO}"
  powerenv block  && powerenv_eval && test -z "${HELLO}"
  powerenv grant  && powerenv_eval && test -n "${HELLO}"
  powerenv revoke && powerenv_eval && test -z "${HELLO}"
test_stop

# shellcheck disable=SC2016
test_start '$test'
  powerenv_eval
  [[ $FOO = bar ]]
test_stop

# Context: foo/bar is a symlink to ../baz. foo/ contains and .envrc file
# BUG: foo/bar is resolved in the .envrc execution context and so can't find
#      the .envrc file.
#
# Apparently, the CHDIR syscall does that so I don't know how to work around
# the issue.
#
# test_start "symlink-bug"
#   cd foo/bar
#   powerenv_eval
# test_stop

# Pending: test that the mtime is looked on the original file
# test_start "utils"
#   LINK_TIME=`powerenv file-mtime link-to-somefile`
#   touch somefile
#   NEW_LINK_TIME=`powerenv file-mtime link-to-somefile`
#   test "$LINK_TIME" = "$NEW_LINK_TIME"
# test_stop
