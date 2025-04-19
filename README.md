# The smart `-` flake

This repo contains a flake that provides an easy way to include language and their dependencies (for example in a `nix shell` environment).


## Usage with `nix shell`

```plain
nix shell <PATH>#<LANGUAGE>[.<PKG1>.<PKG2> ...]
```

- `PATH` is the path of this repo (use `github:tomberek/-`) if you didn't clone it.
- `LANGUAGE` is the name of the language (see [Supported Languages](#supported-languages))
- `PKGS` are the package names (separated by `.`) that will be included with the language


### Make the `<PATH>` shorter

To avoid having to write `github:tomberek/-` each time (which can be quite verbose),
you can run this command in your shell:
```sh
nix registry add flake:lang github:tomberek/-
```
> PS: you can change the registry name to anything you like, `lang` is just an example :)

After, you only have to prefix `lang` as the `<PATH>` of the command.

### Examples

Start a shell environment with python and the packages `scipy`, `matplotlib`, and `numpy`:
```sh
nix shell github:tomberek/-#python3With.scipy.matplotlib.numpy

# If you added the registry
nix shell lang#python3With.scipy.matplotlib.numpy
```

Start a shell environment with perl and the packages `HTMLTokeParserSimple` and `LWP`:
```sh
nix shell github:tomberek/-#perlWith.HTMLTokeParserSimple.LWP

# If you added the registry
nix shell lang#perlWith.HTMLTokeParserSimple.LWP
```



## Usage as a #!-interpreter

```plain
#! /usr/bin/env nix
#! nix shell <PATH>#<LANGUAGE>[.<PKG1>.<PKG2> ...] --command <LANG_EXE>
```

- `PATH` is the path of this repo (use `github:tomberek/-`) if you didn't clone it.
- `LANGUAGE` is the name of the language (see [Supported Languages](#supported-languages))
- `PKGS` are the package names (separated by `.`) that will be included with the language
- `LANG_EXE` is the name of the executable of the language (ex: for python, `LANG_EXE` would by `python` and for perl, it would be `perl -x`)

### Examples

See the [documentation](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-shell) for examples

## Supported Languages

- Python2 (`python2With`)
- Python3 (`python3With`)
- Python39 (`python39With`)
- Python310 (`python310With`)
- Python311 (`python311With`)
- Python312 (`python312With`)
- Python313 (`python313With`)
- Haskell (`haskellWith`)
- Perl (`perlWith`)
