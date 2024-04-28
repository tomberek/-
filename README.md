# The smart `-` flake

This contains a flake that provides easy access to shell environments
(through the `nix shell` command)

## Usage

```plain
nix shell <PATH>#<LANGUAGE>[.<PKG1>.<PKG2> ...]
```

> `PATH` is the path of this repo (use `github:tomberek/-`) if you didn't clone it.
> `LANGUAGE` is the name of the language (see [Supported Languages](#supported-languages))
> `PKGS` are the package names (separated by `.`) that will be included with the language

## Supported Languages

- Python2 (`python2With`)
- Python3 (`python3With`)
- Python39 (`python39With`)
- Python310 (`python310With`)
- Haskell (`haskellWith`)
- Perl (`perlWith`)
