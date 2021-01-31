# getparams

[![CI Status](https://github.com/mikebm94/getparams/workflows/CI/badge.svg)](https://github.com/mikebm94/getparams/actions?query=workflow%3ACI)
[![Latest Release](https://img.shields.io/github/v/release/mikebm94/getparams)](https://github.com/mikebm94/getparams/releases/latest)
[![MIT License](https://img.shields.io/github/license/mikebm94/getparams)](https://github.com/mikebm94/getparams/blob/main/LICENSE)


**getparams** is a flexible command-line option parser. It provides a way to define a conventional command-line interface for shell scripts and parses the parameters passed to them. The output is a series of parameters that are more easily consumed by your shell scripts. Validation is performed to ensure any options you define are used correctly and, when a usage error is encountered, displays a descriptive error message to the user. **getparams** is very similar to the `getopt(1)` command, but it provides some extra features.

Currently, **getparams** is only compatible with shells that use `sh` quoting conventions (such as `bash`, `zsh`, `dash`, `ash`, and `ksh`), and is not compatible with shells using `csh` quoting conventions (such as `tcsh`).

## Table of Contents

* [Dependencies](#dependencies)
* [Installation](#installation)
  * [Custom installation location](#custom-installation-location)
* [Testing](#testing)
  * [Running the test suite](#running-the-test-suite)
  * [Linting with ShellCheck](#linting-with-shellcheck)

## Dependencies

* `bash` (version 3.2 or higher)

## Installation

First clone **getparams** and change into the cloned directory:
```
git clone https://github.com/mikebm94/getparams.git
cd getparams
```

For a system-wide install, run: `sudo make install`

To uninstall, run: `sudo make uninstall`

#### Custom installation location

The default install prefix is `/usr/local`. This can be changed by setting the `PREFIX` environment variable at the beginning of the command.

You can change the destination directory by setting the `DESTDIR` environment variable. The directory will be prepended to the install prefix. This can create a staged installation useful when packaging **getparams**.

When uninstalling, the same `PREFIX` and `DESTDIR` will need to be specified.

## Testing

#### Running the test suite

To run the test suite using Bats (no installation required), run:
```
make test
```

To pass options to `bats`, use the `TESTOPTS` environment variable. For example:
```
TESTOPTS='--timing --tap' make test
```

#### Linting with ShellCheck

To check the source code for issues using ShellCheck (installation required), run:
```
make lint
```

To pass options to `shellcheck`, use the `LINTOPTS` environment variable. For example:
```
LINTOPTS='--format gcc' make lint
```
