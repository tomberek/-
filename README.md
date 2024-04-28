# The smart `-` flake

This repo contains a flake that provides an easy way to include language and their dependencies in your `nix shell` environment.

## Usage

```plain
nix shell <PATH>#<LANGUAGE>[.<PKG1>.<PKG2> ...]
```

- `PATH` is the path of this repo (use `github:tomberek/-`) if you didn't clone it.
- `LANGUAGE` is the name of the language (see [Supported Languages](#supported-languages))
- `PKGS` are the package names (separated by `.`) that will be included with the language

## Supported Languages

- Python2 (`python2With`)
- Python3 (`python3With`)
- Python39 (`python39With`)
- Python310 (`python310With`)
- Haskell (`haskellWith`)
- Perl (`perlWith`)

## Examples

Start a shell environment with python and the packages `scipy`, `matplotlib`, and `numpy`:
```sh
nix shell github:tomberek/-#python3With.scipy.matplotlib.numpy
```

Start a shell environment with perl and the packages `HTMLTokeParserSimple` and `LWP`:
```sh
nix shell github:tomberek/-#perlWith.HTMLTokeParserSimple.LWP
```
