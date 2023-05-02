# Setup

For powerenv to work properly it needs to be hooked into the shell. Each shell
has its own extension mechanism.

Once the hook is configured, restart your shell for powerenv to be activated.

## BASH

Add the following line at the end of the `~/.bashrc` file:

```sh
eval "$(powerenv hook bash)"
```

Make sure it appears even after rvm, git-prompt and other shell extensions
that manipulate the prompt.

## ZSH

Add the following line at the end of the `~/.zshrc` file:

```sh
eval "$(powerenv hook zsh)"
```

## FISH

Add the following line at the end of the `~/.config/fish/config.fish` file:

```fish
powerenv hook fish | source
```

Fish supports 3 modes you can set with the global environment variable `powerenv_fish_mode`:

```fish
set -g powerenv_fish_mode eval_on_arrow    # trigger powerenv at prompt, and on every arrow-based directory change (default)
set -g powerenv_fish_mode eval_after_arrow # trigger powerenv at prompt, and only after arrow-based directory changes before executing command
set -g powerenv_fish_mode disable_arrow    # trigger powerenv at prompt only, this is similar functionality to the original behavior
```

## TCSH

Add the following line at the end of the `~/.cshrc` file:

```sh
eval `powerenv hook tcsh`
```

## Elvish (0.12+)

Run:

```
$> powerenv hook elvish > ~/.elvish/lib/powerenv.elv
```

and add the following line to your `~/.elvish/rc.elv` file:

```
use powerenv
```
