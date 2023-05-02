#!/usr/bin/env tcsh -e

cd `dirname $0`
setenv TEST_DIR $PWD
setenv PATH `dirname $TEST_DIR`:$PATH
setenv XDG_CONFIG_HOME $TEST_DIR/config
setenv XDG_DATA_HOME $TEST_DIR/data

# Reset the powerenv loading if any
setenv powerenv_CONFIG $PWD
unsetenv powerenv_BASH
unsetenv powerenv_DIR
unsetenv powerenv_FILE
unsetenv powerenv_WATCHES
unsetenv powerenv_DIFF

alias powerenv_eval 'eval `powerenv export tcsh`'

# test_start() {
#   cd "$TEST_DIR/scenarios/$1"
#   powerenv allow
#   echo "## Testing $1 ##"
# }


# test_stop {
#   cd $TEST_DIR
#   powerenv_eval
# }

### RUN ###

powerenv allow || true
powerenv_eval

cd $TEST_DIR/scenarios/base
  echo "Testing base"
  powerenv_eval
  test "$HELLO" = "world"

  setenv WATCHES $powerenv_WATCHES
  powerenv_eval
  test "$WATCHES" = "$powerenv_WATCHES"

  sleep 1

  touch .envrc
  powerenv_eval
  test "$WATCHES" != "$powerenv_WATCHES"

  cd ..
  powerenv_eval
  test 0 -eq "$?HELLO"
cd $TEST_DIR ; powerenv_eval

cd $TEST_DIR/scenarios/inherit
  cp ../base/.envrc ../inherited/.envrc
  powerenv allow
  echo "Testing inherit"
  powerenv_eval
  test "$HELLO" = "world"

  sleep 1
  echo "export HELLO=goodbye" > ../inherited/.envrc
  powerenv_eval
  test "$HELLO" = "goodbye"
cd $TEST_DIR ; powerenv_eval

cd $TEST_DIR/scenarios/ruby-layout
  powerenv allow
  echo "Testing ruby-layout"
  powerenv_eval
  test "$GEM_HOME" != ""
cd $TEST_DIR ; powerenv_eval

# Make sure directories with spaces are fine
cd $TEST_DIR/scenarios/"space dir"
  powerenv allow
  echo "Testing space dir"
  powerenv_eval
  test "$SPACE_DIR" = "true"
cd $TEST_DIR ; powerenv_eval

cd $TEST_DIR/scenarios/child-env
  powerenv allow
  echo "Testing child-env"
  powerenv_eval
  test "$PARENT_PRE" = "1"
  test "$CHILD" = "1"
  test "$PARENT_POST" = "1"
  test 0 -eq "$?REMOVE_ME"
cd $TEST_DIR ; powerenv_eval

# cd $TEST_DIR/scenarios/special-vars
#   powerenv allow
#   echo "Testing special-vars"
#   setenv powerenv_BASH `which bash`
#   setenv powerenv_CONFIG foobar
#   powerenv_eval || true
#   test -n "$powerenv_BASH"
#   test "$powerenv_CONFIG" = "foobar"
#   unsetenv powerenv_BASH
#   unsetenv powerenv_CONFIG
# cd $TEST_DIR ; powerenv_eval

cd $TEST_DIR/scenarios/"empty-var"
  powerenv allow
  echo "Testing empty-var"
  powerenv_eval
  test "$?FOO" -eq 1
  test "$FOO" = ""
cd $TEST_DIR ; powerenv_eval

cd $TEST_DIR/scenarios/"empty-var-unset"
  powerenv allow
  echo "Testing empty-var-unset"
  setenv FOO ""
  powerenv_eval
  test "$?FOO" -eq '0'
  unsetenv FOO
cd $TEST_DIR ; powerenv_eval

cd $TEST_DIR/scenarios/"parenthesis"
  powerenv allow
  echo "Testing parenthesis"
  powerenv_eval
  test "$FOO" = "aaa(bbb)ccc"
  unsetenv FOO
cd $TEST_DIR ; powerenv_eval

# Currently broken
# cd $TEST_DIR/scenarios/"utf-8"
#   powerenv allow
#   echo "Testing utf-8"
#   powerenv_eval
#   test "$UTFSTUFF" -eq '♀♂'
# cd $TEST_DIR ; powerenv_eval

# Context: foo/bar is a symlink to ../baz. foo/ contains and .envrc file
# BUG: foo/bar is resolved in the .envrc execution context and so can't find
#      the .envrc file.
#
# Apparently, the CHDIR syscall does that so I don't know how to work around
# the issue.
#
# cd $TEST_DIR/scenarios/"symlink-bug"
#   cd foo/bar
#   powerenv_eval
# cd $TEST_DIR ; powerenv_eval

# Pending: test that the mtime is looked on the original file
# cd $TEST_DIR/scenarios/"utils"
#   LINK_TIME=`powerenv file-mtime link-to-somefile`
#   touch somefile
#   NEW_LINK_TIME=`powerenv file-mtime link-to-somefile`
#   test "$LINK_TIME" = "$NEW_LINK_TIME"
# cd $TEST_DIR ; powerenv_eval
