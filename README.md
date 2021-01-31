# getparams

[![CI Status](https://github.com/mikebm94/getparams/workflows/CI/badge.svg)](https://github.com/mikebm94/getparams/actions?query=workflow%3ACI)
[![Latest Release](https://img.shields.io/github/v/release/mikebm94/getparams)](https://github.com/mikebm94/getparams/releases/latest)
[![MIT License](https://img.shields.io/github/license/mikebm94/getparams)](https://github.com/mikebm94/getparams/blob/main/LICENSE)


**getparams** is a flexible command-line option parser. It provides a way to define a conventional command-line interface for shell scripts and parses the parameters passed to them. The output is a series of parameters that are more easily consumed by your shell scripts. Validation is performed to ensure any options you define are used correctly and, when a usage error is encountered, displays a descriptive error message to the user. **getparams** is very similar to the `getopt(1)` command, but it provides some extra features.

Currently, **getparams** is only compatible with shells that use `sh` quoting conventions (such as `bash`, `zsh`, `dash`, `ash`, and `ksh`), and is not compatible with shells using `csh` quoting conventions (such as `tcsh`).

## Table of Contents

* [How to use](#how-to-use)
  * [Defining recognized options](#defining-recognized-options)
  * [Usage error handling](#usage-error-handling)
  * [Exit codes](#exit-codes)
  * [Examples](#examples)
  * [More information](#more-information)
* [Dependencies](#dependencies)
* [Installation](#installation)
  * [Custom installation location](#custom-installation-location)
* [Testing](#testing)
  * [Running the test suite](#running-the-test-suite)
  * [Linting with ShellCheck](#linting-with-shellcheck)

## How to use

Usage: **getparams** [OPTION]... [-- [PARAM]...]

When invoking **getparams**, you define the options your program will recognize and how they should be used. You can also specify options that change the way **getparams** parses and outputs parameters. Then, after a `--` parameter, pass the parameters that were passed to your program. The standard output of **getparams** can be stored in a temporary variable which can then be evaluated as your programs new parameters.

### Defining recognized options

You can define the short options and/or long options that your program recognizes.

Short options are defined using the `-o` or `--shortopts` option. This option takes an argument consisting of a series single-letter options. The letters do not have to be delimited, but may be delimited by whitespace and/or commas.

Long options are defined using the `-l` or `--longopts` option. This option takes an argument consisting of a series of long option names. The names must be delimited by whitespace and/or commas.

These options are cumulative and may be specified multiple times.

Each short or long option definition may be followed by a `:` to indicate that the option requires an argument, or a `::` to indicate that it accepts an optional argument.

### Usage error handling

**getparams** handles parameter validation for you. If the options you have defined are used incorrectly, an error message describing the problem will be displayed to the user, and **getparams** will return an exit code of `1` to indicate that a usage error has occurred.

You can use the `-n` or `--progname` option to specify your programs name which will be used in the generated error message.

For example, if the user fails to specify a required argument, the following would be displayed:
```
my-program: option '--my-option' requires an argument
```

### Exit codes

* `0` - success
* `1` - usage error encountered when parsing parameters
* `2` - bad usage of **getparams**

### Examples

Here's an example demonstrating basic usage of **getparams**. It's written in Bash, but it could be written in any shell scripting language that supports `sh` quoting conventions.

```bash
#!/usr/bin/env bash

PROGNAME='say-hello'

usage() {
  cat << EOF
Usage: $PROGNAME [-f|--first-name FIRST_NAME] [-l|--last-name LAST_NAME]

Says hello to you

Options:
  -f, --first-name FIRST_NAME  your first name
  -l, --last-name LAST_NAME    your last name
  -h, --help                   display this help and exit

Return Codes:
  0  success
  1  internal error
  2  bad usage
EOF
}

# Invoke getparams, defining our options and passing our parameters.
params="$( getparams -n "$PROGNAME" -o hf:l: -l help,first-name:,last-name: -- "$@" )"

# Check getparams exit code
case $? in
  1)
    # Exit code '1' means our program was used incorrectly.
    # Output a message in addition to the error displayed by getparams.
    >&2 echo "Try '$PROGNAME --help' for more information."
    exit 2
    ;;
  2)
    # Exit code '2' means that we used getparams incorrectly.
    # getparams has displayed an error message describing what went wrong.
    exit 1
    ;;
esac

# Evaluate getparams output as our new parameters.
eval set -- "$params"

first_name=''
last_name=''

while (( $# > 0 )); do
  case "$1" in
    -f|--first-name) shift; first_name="$1" ;;
    -l|--last-name) shift; last_name="$1" ;;
    -h|--help) usage; exit 0 ;;
  esac

  shift
done

echo "Hello $first_name $last_name"
```

In this simple example, **getparams** is already saving us some work. When using our program, the `--first-name` and `--last-name` options can be abbreviated, for example, as `--first` and `--last`. Also, we don't have to check if an unrecognized option was specified, or check whether a required argument was unspecified (of course, we should still check if the argument is an empty string.)

The arguments can be specified to our options in a number of ways, for example:
```
say-hello --first FOO --last BAR
say-hello --first=FOO --last=BAR
say-hello -f FOO --l BAR
say-hello -fFOO -lBAR
```

Would all output `Hello, FOO BAR`.

### More information

We've only gone over a few of the options/features available, and haven't gone over in depth how **getparams** parses and outputs parameters. For more information, run `man getparams` to view the manual.

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

### Custom installation location

The default install prefix is `/usr/local`. This can be changed by setting the `PREFIX` environment variable at the beginning of the command.

You can change the destination directory by setting the `DESTDIR` environment variable. The directory will be prepended to the install prefix. This can create a staged installation useful when packaging **getparams**.

When uninstalling, the same `PREFIX` and `DESTDIR` will need to be specified.

## Testing

### Running the test suite

To run the test suite using Bats (no installation required), run:
```
make test
```

To pass options to `bats`, use the `TESTOPTS` environment variable. For example:
```
TESTOPTS='--timing --tap' make test
```

### Linting with ShellCheck

To check the source code for issues using ShellCheck (installation required), run:
```
make lint
```

To pass options to `shellcheck`, use the `LINTOPTS` environment variable. For example:
```
LINTOPTS='--format gcc' make lint
```
