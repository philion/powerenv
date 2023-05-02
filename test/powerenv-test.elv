#!/usr/bin/env elvish

use path

E:TEST_DIR = (path:dir (src)[name])
set-env XDG_CONFIG_HOME $E:TEST_DIR/config
set-env XDG_DATA_HOME $E:TEST_DIR/data
E:PATH = (path:dir $E:TEST_DIR):$E:PATH

cd $E:TEST_DIR

## reset the powerenv loading if any
set-env powerenv_CONFIG $pwd
unset-env powerenv_BASH
unset-env powerenv_DIR
unset-env powerenv_FILE
unset-env powerenv_WATCHES
unset-env powerenv_DIFF

mkdir -p $E:XDG_CONFIG_HOME/powerenv
touch $E:XDG_CONFIG_HOME/powerenv/powerenvrc

fn powerenv-eval {
	try {
		m = (powerenv export elvish | from-json)
		keys $m | each [k]{
			if $m[$k] {
				set-env $k $m[$k]
			} else {
				unset-env $k
			}
		}
	} except e {
		nop
	}
}

fn test-debug {
	if (==s $E:powerenv_DEBUG "1") {
		echo
	}
}

fn test-eq [a b]{
	if (!=s $a $b) {
		fail "FAILED: '"$a"' == '"$b"'"
	}
}

fn test-neq [a b]{
	if (==s $a $b) {
		fail "FAILED: '"$a"' != '"$b"'"
	}
}

fn test-scenario [name fct]{
	cd $E:TEST_DIR/scenarios/$name
	powerenv allow
	test-debug
	echo "\n## Testing "$name" ##"
	test-debug

	$fct

	cd $E:TEST_DIR
	powerenv-eval
}


### RUN ###

try {
	powerenv allow
} except e {
	nop
}

powerenv-eval

test-scenario base {
	echo "Setting up"
	powerenv-eval
	test-eq $E:HELLO "world"

	set E:WATCHES = $E:powerenv_WATCHES

	echo "Reloading (should be no-op)"
	powerenv-eval
	test-eq $E:WATCHES $E:powerenv_WATCHES

	sleep 1

	echo "Updating envrc and reloading (should reload)"
	touch .envrc
	powerenv-eval
	test-neq $E:WATCHES $E:powerenv_WATCHES

	echo "Leaving dir (should clear env set by dir's envrc)"
	cd ..
	powerenv-eval
	test-eq $E:HELLO ""
}

test-scenario inherit {
	cp ../base/.envrc ../inherited/.envrc
	powerenv-eval
	echo "HELLO should be world:"$E:HELLO
	test-eq $E:HELLO "world"

	sleep 1
	echo "export HELLO=goodbye" > ../inherited/.envrc
	powerenv-eval
	test-eq $E:HELLO "goodbye"
}

test-scenario "ruby-layout" {
	powerenv-eval
	test-neq $E:GEM_HOME ""
}

test-scenario "space dir" {
	powerenv-eval
	test-eq $E:SPACE_DIR "true"
}

test-scenario "child-env" {
	powerenv-eval
	test-eq $E:PARENT_PRE "1"
	test-eq $E:CHILD "1"
	test-eq $E:PARENT_POST "1"
	test-eq $E:REMOVE_ME ""
}

test-scenario "utf-8" {
	powerenv-eval
	test-eq $E:UTFSTUFF "♀♂"
}

## TODO: special-vars
## TODO: dump
## TODO: empty-var
## TODO: empty-var-unset

test-scenario "missing-file-source-env" {
	powerenv-eval
}
