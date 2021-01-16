#!/usr/bin/env bats

load '../tools/bats-support/load.bash'
load '../tools/bats-assert/load.bash'

readonly GETPARAMS="${BATS_TEST_DIRNAME%/*}/bin/getparams"

@test "parsing: shortopts (0)" {
  run "${GETPARAMS}" --shortopts=abcd -- -a -b -cd
  assert_success
  assert_output "-a -b -c -d -- "
}

@test "parsing: shortopt argument [required - unspecified] fails (1)" {
  run "${GETPARAMS}" --shortopts=a: -- -a
  assert_failure 1
  assert_output --partial "option 'a' requires an argument"

  run "${GETPARAMS}" --shortopts=abc: -- -abc
  assert_failure 1
  assert_output --partial "option 'c' requires an argument"
}

@test "parsing: shortopt argument [required - same parameter] (0)" {
  run "${GETPARAMS}" --shortopts=a:bc: -- -aFOO -bcBAR
  assert_success
  assert_output "-a 'FOO' -b -c 'BAR' -- "
}

@test "parsing: shortopt argument [required - next parameter] (0)" {
  run "${GETPARAMS}" --shortopts=a:bc: -- -a FOO -bc BAR
  assert_success
  assert_output "-a 'FOO' -b -c 'BAR' -- "
}

@test "parsing: shortopt argument [optional - unspecified] (0)" {
  run "${GETPARAMS}" --shortopts=a::bc:: -- -a -bc
  assert_success
  assert_output "-a '' -b -c '' -- "
}

@test "parsing: shortopt argument [optional - specified] (0)" {
  run "${GETPARAMS}" --shortopts=a::bc:: -- -aFOO -bcBAR
  assert_success
  assert_output "-a 'FOO' -b -c 'BAR' -- "
}

@test "parsing: unrecognized shortopt fails (1)" {
  run "${GETPARAMS}" --shortopts=a -- -a -B
  assert_failure 1
  assert_output --partial "unrecognized option 'B'"

  run "${GETPARAMS}" --shortopts=c -- -cD
  assert_failure 1
  assert_output --partial "unrecognized option 'D'"
}

@test "parsing: unrecognized shortopt fails [--stop-signal=non-opt] (1)" {
  run "${GETPARAMS}" --stop-signal=non-opt --shortopts=a -- -a -B
  assert_failure 1
  assert_output --partial "unrecognized option 'B'"

  run "${GETPARAMS}" --stop-signal=non-opt --shortopts=c -- -cD
  assert_failure 1
  assert_output --partial "unrecognized option 'D'"
}

@test "parsing: unrecognized shortopt stops parsing [--stop-signal=unknown-opt] (0)" {
  run "${GETPARAMS}" --stop-signal=unknown-opt --shortopts=ab -- -a -X -b
  assert_success
  assert_output "-a -- '-X' '-b'"

  run "${GETPARAMS}" --stop-signal=unknown-opt --shortopts=cd -- -cY -d
  assert_success
  assert_output " -- '-cY' '-d'"
}

@test "parsing: longopts (0)" {
  run "${GETPARAMS}" --longopts=foo,bar -- --foo --bar
  assert_success
  assert_output "--foo --bar -- "
}

@test "parsing: longopt names can be abbreviated (0)" {
  run "${GETPARAMS}" --longopts=foobar -- --foo
  assert_success
  assert_output "--foobar -- "
}

@test "parsing: longopt ambiguous abbreviation fails (1)" {
  run "${GETPARAMS}" --longopts=foobar,foobaz -- --foo
  assert_failure 1
  assert_output --partial \
    "ambiguous option '--foo': possibilities: --foobar --foobaz"
}

@test "parsing: longopt ambiguous abbreviation with an exact match succeeds (0)" {
  run "${GETPARAMS}" --longopts=foobar,foobaz,foo -- --foo
  assert_success
  assert_output "--foo -- "
}

@test "parsing: longopt argument [required - unspecified] fails (1)" {
  run "${GETPARAMS}" --longopts=foo: -- --foo
  assert_failure 1
  assert_output --partial "option '--foo' requires an argument"
}

@test "parsing: longopt argument [required - same parameter] (0)" {
  run "${GETPARAMS}" --longopts=foo: -- --foo=BAR
  assert_success
  assert_output "--foo 'BAR' -- "
}

@test "parsing: longopt argument [required - next parameter] (0)" {
  run "${GETPARAMS}" --longopts=foo: -- --foo BAR
  assert_success "--foo 'BAR' -- "
}

@test "parsing: longopt argument [optional - unspecified] (0)" {
  run "${GETPARAMS}" --longopts=foo:: -- --foo
  assert_success
  assert_output "--foo '' -- "
}

@test "parsing: longopt argument [optional - specified] (0)" {
  run "${GETPARAMS}" --longopts=foo:: -- --foo=BAR
  assert_success
  assert_output "--foo 'BAR' -- "
}

@test "parsing: longopt argument [optional - specified empty] (0)" {
  run "${GETPARAMS}" --longopts=foo:: -- --foo=''
  assert_success
  assert_output "--foo '' -- "
}

@test "parsing: longopt argument [unwanted - specified] fails (1)" {
  run "${GETPARAMS}" --longopts=foo -- --foo=BAR
  assert_failure 1
  assert_output --partial "option '--foo' doesn't accept an argument"
}

@test "parsing: unrecognized longopt fails (1)" {
  run "${GETPARAMS}" --longopts=foo -- --foo --bar
  assert_failure 1
  assert_output --partial "unrecognized option '--bar'"
}

@test "parsing: unrecognized longopt fails [--stop-signal=non-opt] (1)" {
  run "${GETPARAMS}" --stop-signal=non-opt --longopts=foo -- --foo --bar
  assert_failure 1
  assert_output --partial "unrecognized option '--bar'"
}

@test "parsing: unrecognized longopt stops parsing [--stop-signal=unknown-opt] (0)" {
  run "${GETPARAMS}" --stop-signal=unknown-opt --longopts=foo,bar -- --foo --BAZ --bar
  assert_success
  assert_output "--foo -- '--BAZ' '--bar'"
}

@test "parsing: option after option with required argument is interpreted as the argument (0)" {
  run "${GETPARAMS}" --shortopts=a:b: --longopts=foo:,bar: -- -a -b --foo --bar
  assert_success
  assert_output "-a '-b' --foo '--bar' -- "
}

@test "parsing: parameter after option with optional argument is interpreted as a non-opt (0)" {
  run "${GETPARAMS}" --shortopts=a:: --longopts=foo:: -- -a FIZZ --foo BUZZ
  assert_success
  assert_output "-a '' --foo '' -- 'FIZZ' 'BUZZ'"
}

@test "parsing: '--' parameter stops parsing (0)" {
  run "${GETPARAMS}" --shortopts=ab -- -a -- -b
  assert_success
  assert_output "-a -- '-b'"
}

@test "parsing: first non-option parameter stops parsing [--stop-signal=non-opt] (0)" {
  run "${GETPARAMS}" --stop-signal=non-opt --shortopts=ab -- -a FOO -b
  assert_success
  assert_output "-a -- 'FOO' '-b'"
}

@test "parsing: first non-option parameter stops parsing [--stop-signal=unknown-opt] (0)" {
  run "${GETPARAMS}" --stop-signal=unknown-opt --shortopts=ab -- -a FOO -b
  assert_success
  assert_output "-a -- 'FOO' '-b'"
}

# vim: expandtab:ts=2:sw=0
