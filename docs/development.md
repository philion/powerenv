# Development

Setup a go environment https://golang.org/doc/install

> go >= 1.16 is required

Clone the project:

    $ git clone git@github.com:powerenv/powerenv.git

Build by just typing make:

    $ cd powerenv
    $ make

Test the projects:

    $ make test

To install to /usr/local:

    $ make install

Or to a different location like `~/.local`:

    $ make install PREFIX=~/.local
