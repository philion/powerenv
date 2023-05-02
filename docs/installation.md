# Installation

The installation has two parts.

1. Install the package or binary, which is presented in this document
2. [hook into your shell](hook.md).

## From system packages

powerenv is packaged for a variety of systems:

* [Fedora](https://src.fedoraproject.org/rpms/powerenv)
* [Arch Linux](https://archlinux.org/packages/community/x86_64/powerenv/)
* [Debian](https://packages.debian.org/search?keywords=powerenv&searchon=names&suite=all&section=all)
* [Gentoo go-overlay](https://github.com/Dr-Terrible/go-overlay)
* [NetBSD pkgsrc-wip](http://www.pkgsrc.org/wip/)
* [NixOS](https://nixos.org/nixos/packages.html?query=powerenv)
* [macOS Homebrew](https://formulae.brew.sh/formula/powerenv#default)
* [openSUSE](https://build.opensuse.org/package/show/openSUSE%3AFactory/powerenv)
* [MacPorts](https://ports.macports.org/port/powerenv/)
* [Ubuntu](https://packages.ubuntu.com/search?keywords=powerenv&searchon=names&suite=all&section=all)
* [GNU Guix](https://www.gnu.org/software/guix/)

See also:

[![Packaging status](https://repology.org/badge/vertical-allrepos/powerenv.svg)](https://repology.org/metapackage/powerenv)

## From binary builds

To install binary builds you can run this bash installer:

```sh
curl -sfL https://powerenv.net/install.sh | bash
```

Binary builds for a variety of architectures are also available for
[each release](https://github.com/powerenv/powerenv/releases).

Fetch the binary, `chmod +x powerenv` and put it somewhere in your `PATH`.

## Compile from source

See the [Development](development.md) page.

# Next step

[hook installation](hook.md)
