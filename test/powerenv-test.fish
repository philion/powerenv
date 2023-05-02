#!/usr/bin/env fish
function test_eq --argument-names a b
    if not test (count $argv) = 2
        echo "Error: " (count $argv) " arguments passed to `eq`: $argv"
        exit 1
    end

    if not test $a = $b
        printf "Error:\n - expected: %s\n -      got: %s\n" "$a" "$b"
        exit 1
    end
end

function test_neq --argument-names a b
    if not test (count $argv) = 2
        echo "Error: " (count $argv) " arguments passed to `neq`: $argv"
        exit 1
    end

    if test $a = $b
        printf "Error:\n - expected: %s\n -      got: %s\n" "$a" "$b"
        exit 1
    end
end

function has
    type -q $argv[1]
end

cd (dirname (status -f))
set TEST_DIR $PWD
set XDG_CONFIG_HOME $TEST_DIR/config
set XDG_DATA_HOME $TEST_DIR/data
set -gx PATH (dirname $TEST_DIR) $PATH

# Reset the powerenv loading if any
set -x powerenv_CONFIG $PWD
set -e powerenv_BASH
set -e powerenv_DIR
set -e powerenv_FILE
set -e powerenv_WATCHES
set -e powerenv_DIFF

function powerenv_eval
    #powerenv export fish # for debugging
    powerenv export fish | source
end

function test_start -a name
    cd "$TEST_DIR/scenarios/$name"
    powerenv allow
    echo "## Testing $name ##"
end

function test_stop
    cd /
    powerenv_eval
end

### RUN ###

powerenv allow
powerenv_eval

test_start base
begin
    echo "Setting up"
    powerenv_eval
    test_eq "$HELLO" world

    set WATCHES $powerenv_WATCHES

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
    echo $HELLO
    test -z "$HELLO" || exit 1

    set -e WATCHES
end
test_stop

test_start inherit
begin
    cp ../base/.envrc ../inherited/.envrc
    powerenv_eval
    echo "HELLO should be world:" "$HELLO"

    sleep 1
    echo "export HELLO=goodbye" >../inherited/.envrc
    powerenv_eval
    test_eq "$HELLO" goodbye
end
test_stop

if has ruby
    test_start ruby-layout
    begin
        powerenv_eval
        test_neq "$GEM_HOME" ""
    end
    test_stop
end

# Make sure directories with spaces are fine
test_start "space dir"
begin
    powerenv_eval
    test_eq "$SPACE_DIR" true
end
test_stop

test_start child-env
begin
    powerenv_eval
    test_eq "$PARENT_PRE" 1
    test_eq "$CHILD" 1
    test_eq "$PARENT_POST" 1
    test -z "$REMOVE_ME" || exit 1
end
test_stop

test_start special-vars
begin
    set -x powerenv_BASH (command -s bash)
    set -x powerenv_CONFIG foobar
    powerenv_eval || true
    test -n "$powerenv_BASH" || exit 1
    test_eq "$powerenv_CONFIG" foobar
    set -e powerenv_BASH
    set -e powerenv_CONFIG
end
test_stop

test_start dump
begin
    set -e LS_COLORS
    powerenv_eval
    test_eq "$LS_COLORS" "*.ogg=38;5;45:*.wav=38;5;45"
    test_eq "$LESSOPEN" "||/usr/bin/lesspipe.sh %s"
    test_eq "$THREE_BACKSLASHES" "\\\\\\"
end
test_stop

test_start empty-var
begin
    powerenv_eval
    set -q FOO || exit 1
    test_eq "$FOO" ""
end
test_stop

test_start empty-var-unset
begin
    set -x FOO ""
    powerenv_eval
    set -q FOO && exit 1
    set -e FOO
end
test_stop

test_start in-envrc
begin
    powerenv_eval
    ./test-in-envrc
    test_eq $status 1
end
test_stop

test_start missing-file-source-env
begin
    powerenv_eval
end
test_stop

test_start symlink-changed
begin
    # when using a symlink, reload if the symlink changes, or if the
    # target file changes.
    ln -fs ./state-A ./symlink
    powerenv_eval
    test_eq "$STATE" A
    sleep 1

    ln -fs ./state-B ./symlink
    powerenv_eval
    test_eq "$STATE" B
end
test_stop

# Currently broken
# test_start utf-8
# begin
#     powerenv_eval
#     test_eq "$UTFSTUFF" "♀♂"
# end
# test_stop

test_start failure
begin
    # Test that powerenv_DIFF and powerenv_WATCHES are set even after a failure.
    #
    # This is needed so that powerenv doesn't go into a loop when the loading
    # fails.

    test_eq "$powerenv_DIFF" ""
    test_eq "$powerenv_WATCHES" ""

    powerenv_eval

    test_neq "$powerenv_DIFF" ""
    test_neq "$powerenv_WATCHES" ""

end
test_stop

test_start watch-dir
begin
    echo "No watches by default"
    test_eq "$powerenv_WATCHES" "$WATCHES"

    powerenv_eval

    if ! powerenv show_dump $powerenv_WATCHES | grep -q testfile
        echo "FAILED: testfile not added to powerenv_WATCHES"
        exit 1
    end

    echo "After eval, watches have changed"
    test_neq "$powerenv_WATCHES" "$WATCHES"
end
test_stop
