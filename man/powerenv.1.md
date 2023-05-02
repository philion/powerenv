powerenv 1 "2019" powerenv "User Manuals"
===========================================

NAME
----

powerenv - unclutter your .profile

SYNOPSIS
--------

`powerenv` *command* ...

DESCRIPTION
-----------

`powerenv` is an environment variable manager for your shell. It knows how to
hook into bash, zsh and fish shell to load or unload environment variables
depending on your current directory. This allows you to have project-specific
environment variables and not clutter the "~/.profile" file.

Before each prompt it checks for the existence of an `.envrc` file in the
current and parent directories. If the file exists, it is loaded into a bash
sub-shell and all exported variables are then captured by powerenv and then made
available to your current shell, while unset variables are removed.

Because powerenv is compiled into a single static executable it is fast enough
to be unnoticeable on each prompt. It is also language agnostic and can be
used to build solutions similar to rbenv, pyenv, phpenv, ...

EXAMPLE
-------

```
$ cd ~/my_project
$ echo ${FOO-nope}
nope
$ echo export FOO=foo > .envrc
\.envrc is not allowed
$ powerenv allow .
powerenv: reloading
powerenv: loading .envrc
powerenv export: +FOO
$ echo ${FOO-nope}
foo
$ cd ..
powerenv: unloading
powerenv export: ~PATH
$ echo ${FOO-nope}
nope
```

SETUP
-----

For powerenv to work properly it needs to be hooked into the shell. Each shell
has it's own extension mechanism:

### BASH

Add the following line at the end of the `~/.bashrc` file:

```sh
eval "$(powerenv hook bash)"
```

Make sure it appears even after rvm, git-prompt and other shell extensions
that manipulate the prompt.

### ZSH

Add the following line at the end of the `~/.zshrc` file:

```sh
eval "$(powerenv hook zsh)"
```

### FISH

Add the following line at the end of the `$XDG_CONFIG_HOME/fish/config.fish` file:

```fish
powerenv hook fish | source
```

Fish supports 3 modes you can set with with the global environment variable `powerenv_fish_mode`:

```fish
set -g powerenv_fish_mode eval_on_arrow    # trigger powerenv at prompt, and on every arrow-based directory change (default)
set -g powerenv_fish_mode eval_after_arrow # trigger powerenv at prompt, and only after arrow-based directory changes before executing command
set -g powerenv_fish_mode disable_arrow    # trigger powerenv at prompt only, this is similar functionality to the original behavior
```


### TCSH

Add the following line at the end of the `~/.cshrc` file:

```sh
eval `powerenv hook tcsh`
```

### Elvish

Run:

```
$> powerenv hook elvish > ~/.elvish/lib/powerenv.elv
```

and add the following line to your `~/.elvish/rc.elv` file:

```
use powerenv
```

USAGE
-----

In some target folder, create an `.envrc` file and add some export(1)
and unset(1) directives in it.

On the next prompt you will notice that powerenv complains about the `.envrc`
being blocked. This is the security mechanism to avoid loading new files
automatically. Otherwise any git repo that you pull, or tar archive that you
unpack, would be able to wipe your hard drive once you `cd` into it.

So here we are pretty sure that it won't do anything bad. Type `powerenv allow .`
and watch powerenv loading your new environment. Note that `powerenv edit .` is a
handy shortcut that opens the file in your $EDITOR and automatically reloads it
if the file's modification time has changed.

Now that the environment is loaded you can notice that once you `cd` out
of the directory it automatically gets unloaded. If you `cd` back into it it's
loaded again. That's the base of the mechanism that allows you to build cool
things.

Exporting variables by hand is a bit repetitive so powerenv provides a set of
utility functions that are made available in the context of the `.envrc` file.
Check the powerenv-stdlib(1) man page for more details. You can also define your
own extensions inside `$XDG_CONFIG_HOME/powerenv/powerenvrc` or
`$XDG_CONFIG_HOME/powerenv/lib/*.sh` files.

Hopefully this is enough to get you started.

ENVIRONMENT
-----------

`XDG_CONFIG_HOME`
: Defaults to `$HOME/.config`.

FILES
-----

`$XDG_CONFIG_HOME/powerenv/powerenv.toml`
: powerenv configuration. See powerenv.toml(1).

`$XDG_CONFIG_HOME/powerenv/powerenvrc`
: Bash code loaded before every `.envrc`. Good for personal extensions.

`$XDG_CONFIG_HOME/powerenv/lib/*.sh`
: Bash code loaded before every `.envrc`. Good for third-party extensions.

`$XDG_DATA_HOME/powerenv/allow`
: Records which `.envrc` files have been `powerenv allow`ed.

CONTRIBUTE
----------

Bug reports, contributions and forks are welcome.

All bugs or other forms of discussion happen on
<http://github.com/powerenv/powerenv/issues>

There is also a wiki available where you can share your usage patterns or
other tips and tricks <https://github.com/powerenv/powerenv/wiki>

Or drop by on the [#powerenv channel on FreeNode](irc://#powerenv@FreeNode) to
have a chat.

COPYRIGHT
---------

MIT licence - Copyright (C) 2019 @zimbatm and contributors

SEE ALSO
--------

powerenv-stdlib(1), powerenv.toml(1), powerenv-fetchurl(1)
