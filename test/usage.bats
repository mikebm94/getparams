#!/usr/bin/env bats

load '../tools/bats-support/load.bash'
load '../tools/bats-assert/load.bash'

readonly GETPARAMS="${BATS_TEST_DIRNAME%/*}/bin/getparams"

@test "usage: no parameters outputs ' -- ' (0)" {
  run "${GETPARAMS}"
  assert_success
  assert_output " -- "
}

@test "usage: non-option parameter '-' fails (2)" {
  run "${GETPARAMS}" -
  assert_failure 2
  assert_line -n 0 --partial "unexpected parameter '-'"
}

@test "usage: non-option parameter 'foo' fails (2)" {
  run "${GETPARAMS}" foo
  assert_failure 2
  assert_line -n 0 --partial "unexpected parameter 'foo'"
}

@test "usage: unrecognized option '-Z' fails (2)" {
  run "${GETPARAMS}" -Z
  assert_failure 2
  assert_line -n 0 --partial "unrecognized option 'Z'"
}

@test "usage: unrecognized option '--foo' fails (2)" {
  run "${GETPARAMS}" --foo
  assert_failure 2
  assert_line -n 0 --partial "unrecognized option '--foo'"
}

@test "usage: --stop-signal: no argument fails (2)" {
  run "${GETPARAMS}" --stop-signal
  assert_failure 2
  assert_line -n 0 --partial "option '--stop-signal' requires an argument"
}

@test "usage: --stop-signal: bad argument fails (2)" {
  run "${GETPARAMS}" --stop-signal=foobar
  assert_failure 2
  assert_line -n 0 --partial \
    "invalid argument 'foobar' for option '--stop-signal'"
}

@test "usage: --stop-signal: argument can be abbreviated (0)" {
  run "${GETPARAMS}" --stop-signal=exp --stop-signal=non --stop-signal=unk
  assert_success
}

@test "usage: --shortopts: no argument fails (2)" {
  run "${GETPARAMS}" --shortopts
  assert_failure 2
  assert_line -n 0 --partial "option '--shortopts' requires an argument"
}

@test "usage: --shortopts: definition with bad character fails (2)" {
  run "${GETPARAMS}" --shortopts='ab:c::d&e:'
  assert_failure 2
  assert_line -n 0 --partial \
    "invalid short option definition '&' in argument for option '--shortopts'"
}

@test "usage: --shortopts: mixed and extra delimiters are handled (0)" {
  run "${GETPARAMS}" --shortopts=' ,ab,c, d ,, e, ' -- -a -b -c -d
  assert_success
  assert_output "-a -b -c -d -- "

  run "${GETPARAMS}" --shortopts=' ,ab,c, d ,, e, ' -- -a -b -c -d
  assert_success
  assert_output "-a -b -c -d -- "
}

@test "usage: --shortopts: arguments are accumulated (0)" {
  run "${GETPARAMS}" --shortopts=ab --shortopts=cd -- -a -b -c -d
  assert_success
  assert_output "-a -b -c -d -- "
}

@test "usage: --longopts: no argument fails (2)" {
  run "${GETPARAMS}" --longopts
  assert_failure 2
  assert_line -n 0 --partial "option '--longopts' requires an argument"
}

@test "usage: --longopts: definition with bad character fails (2)" {
  run "${GETPARAMS}" --longopts='foo::,bar&::'
  assert_failure 2
  assert_line -n 0 --partial \
    "invalid long option definition 'bar&::' in argument for option '--longopts'"
}

@test "usage: --longopts: definition with name length < 2 fails (2)" {
  run "${GETPARAMS}" --longopts='f::'
  assert_failure 2
  assert_line -n 0 --partial \
    "invalid long option definition 'f::' in argument for option '--longopts'"
}

@test "usage: --longopts: mixed and extra delimiters are handled (0)" {
  run "${GETPARAMS}" --longopts=' ,foo,bar, baz fizz ,, buzz, ' -- \
    --foo --bar --baz --fizz --buzz
  assert_success
  assert_output "--foo --bar --baz --fizz --buzz -- "
}

@test "usage: --longopts: arguments are accumulated (0)" {
  run "${GETPARAMS}" --longopts=foo,bar --longopts=fizz,buzz -- \
    --foo --bar --fizz --buzz
  assert_success
  assert_output "--foo --bar --fizz --buzz -- "
}

@test "usage: --progname: no argument fails (2)" {
  run "${GETPARAMS}" --progname
  assert_failure 2
  assert_line -n 0 --partial "option '--progname' requires an argument"
}

@test "usage: --help prints usage (0)" {
  run "${GETPARAMS}" --help
  assert_success
  assert_line -n 0 --partial "Usage: "
}

@test "usage: --version prints version (0)" {
  run "${GETPARAMS}" --version
  assert_success
  assert_output --partial "getparams "
}

# vim: expandtab:ts=2:sw=0
