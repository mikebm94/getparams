#!/usr/bin/env bats

readonly BIN_GETPARAMS="${BATS_TEST_DIRNAME%/*}/bin/getparams"

print_result() {
  echo "STATUS: $1"
  echo "OUTPUT: \"$2\""
}


@test "no parameters (0)" {
  run "${BIN_GETPARAMS}"
  
  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = " -- " ]
}

@test "bad usage - unexpected parameter '-' (2)" {
  run "${BIN_GETPARAMS}" -

  print_result "${status}" "${output}"
  [ "${status}" -eq 2 ]
}

@test "bad usage - unexpected parameter 'foo' (2)" {
  run "${BIN_GETPARAMS}" foo

  print_result "${status}" "${output}"
  [ "${status}" -eq 2 ]
}

@test "bad usage - bad argument for '--stop-signal' (2)" {
  run "${BIN_GETPARAMS}" --stop-signal=foo

  print_result "${status}" "${output}"
  [ "${status}" -eq 2 ]
}

@test "bad usage - bad definition for '--shortopts' (2)" {
  run "${BIN_GETPARAMS}" --shortopts='a:b:c::&:'

  print_result "${status}" "${output}"
  [ "${status}" -eq 2 ]
}

@test "bad usage - bad definition for '--longopts' [invalid character] (2)" {
  run "${BIN_GETPARAMS}" --longopts='foo,bar:,baz::,boo&'

  print_result "${status}" "${output}"
  [ "${status}" -eq 2 ]
}

@test "bad usage - bad definition for '--longopts' [too short] (2)" {
  run "${BIN_GETPARAMS}" --longopts=f

  print_result "${status}" "${output}"
  [ "${status}" -eq 2 ]
}

@test "usage - abbreviate '--stop-signal' argument (0)" {
  run "${BIN_GETPARAMS}" --stop-signal=un

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
}

@test "single quotes are escaped (0)" {
  run "${BIN_GETPARAMS}" -- "Here's johnny"

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = " -- 'Here'\\''s johnny'" ]
}

@test "short option (0)" {
  run "${BIN_GETPARAMS}" --shortopts=a -- -a

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a -- " ]
}

@test "short option group (0)" {
  run "${BIN_GETPARAMS}" --shortopts=abc -- -abc

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a -b -c -- " ]
}

@test "short options w/ mixed/extra delimiters (0)" {
  run "${BIN_GETPARAMS}" --shortopts=' ,, ,a bc,, ,,d , ' -- -a -b -c -d

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a -b -c -d -- " ]
}

@test "short option argument [required - current parameter] (0)" {
  run "${BIN_GETPARAMS}" --shortopts=a: -- -afoo

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a='foo' -- " ]
}

@test "short option argument [required - next parameter] (0)" {
  run "${BIN_GETPARAMS}" --shortopts=a: -- -a --foo

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a='--foo' -- " ]
}

@test "short option group argument [required - current parameter] (0)" {
  run "${BIN_GETPARAMS}" --shortopts=abc: -- -abcfoo

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a -b -c='foo' -- " ]
}

@test "short option group argument [required - next parameter] (0)" {
  run "${BIN_GETPARAMS}" --shortopts=abc: -- -abc --foo

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a -b -c='--foo' -- " ]
}

@test "short option argument [optional] (0)" {
  run "${BIN_GETPARAMS}" --shortopts=a:: -- -afoo

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a='foo' -- " ]
}

@test "short option group argument [optional] (0)" {
  run "${BIN_GETPARAMS}" --shortopts=abc:: -- -abcfoo

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a -b -c='foo' -- " ]
}

@test "long option (0)" {
  run "${BIN_GETPARAMS}" --longopts=foo -- --foo

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "--foo -- " ]
}

@test "long options w/ mixed/extra delimiters (0)" {
  run "${BIN_GETPARAMS}" --longopts=' ,,foo,bar baz ,,, boo ,, ' -- \
    --foo --bar --baz --boo
  
  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "--foo --bar --baz --boo -- " ]
}

@test "long option [abbreviated] (0)" {
  run "${BIN_GETPARAMS}" --longopts=foobar -- --foo

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "--foobar -- " ]
}

@test "long option [ambiguous abbreviation] (1)" {
  run "${BIN_GETPARAMS}" --longopts=foobar,foobaz -- --foo

  print_result "${status}" "${output}"
  [ "${status}" -eq 1 ]
}

@test "long option [exact match - ambiguous abbreviation] (0)" {
  run "${BIN_GETPARAMS}" --longopts=foobar,foo -- --foo

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "--foo -- " ]
}

@test "long option argument [required - current parameter] (0)" {
  run "${BIN_GETPARAMS}" --longopts=foo: -- --foo=bar

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "--foo='bar' -- " ]
}

@test "long option argument [required - next parameter] (0)" {
  run "${BIN_GETPARAMS}" --longopts=foo: -- --foo --bar

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "--foo='--bar' -- " ]
}

@test "long option argument [optional] (0)" {
  run "${BIN_GETPARAMS}" --longopts=foo:: -- --foo=bar

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "--foo='bar' -- " ]
}

@test "unwanted long option argument (1)" {
  run "${BIN_GETPARAMS}" --longopts=foo -- --foo=bar

  print_result "${status}" "${output}"
  [ "${status}" -eq 1 ]
}

@test "parameter after short option with optional argument is non-opt (0)" {
  run "${BIN_GETPARAMS}" --shortopts=a:: -- -a foo

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a -- 'foo'" ]
}

@test "parameter after long option with optional argument is non-opt (0)" {
  run "${BIN_GETPARAMS}" --longopts=foo:: -- --foo bar

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "--foo -- 'bar'" ]
}

@test "unknown short option (1)" {
  run "${BIN_GETPARAMS}" -- -a

  print_result "${status}" "${output}"
  [ "${status}" -eq 1 ]
}

@test "unknown short option in group (1)" {
  run "${BIN_GETPARAMS}" --shortopts=ac -- -abc

  print_result "${status}" "${output}"
  [ "${status}" -eq 1 ]
}

@test "unknown long option (1)" {
  run "${BIN_GETPARAMS}" -- --foo

  print_result "${status}" "${output}"
  [ "${status}" -eq 1 ]
}

@test "'--' stops parsing (0)" {
  run "${BIN_GETPARAMS}" --shortopts=abc -- -a -- -b -c

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a -- '-b' '-c'" ]
}

@test "reorganizes non-opts (0)" {
  run "${BIN_GETPARAMS}" --shortopts=abc -- -a foo -b bar -c baz -- boo

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a -b -c -- 'foo' 'bar' 'baz' 'boo'" ]
}

@test "keeps non-opt order (0)" {
  run "${BIN_GETPARAMS}" --keep-order --shortopts=abc -- \
    -a foo -b bar -c baz -- boo
  
  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a 'foo' -b 'bar' -c 'baz' -- 'boo'" ]
}

@test "stop-signal=non-opt - first non-opt stops parsing (0)" {
  run "${BIN_GETPARAMS}" --stop-signal=non-opt --shortopts=abc -- \
    -a -b foo -c
  
  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a -b -- 'foo' '-c'" ]
}

@test "stop-signal=non-opt - unknown short option fails (1)" {
  run "${BIN_GETPARAMS}" --stop-signal=non-opt -- -a

  print_result "${status}" "${output}"
  [ "${status}" -eq 1 ]
}

@test "stop-signal=non-opt - unknown short option in group fails (1)" {
  run "${BIN_GETPARAMS}" --stop-signal=non-opt --shortopts=ac -- -abc

  print_result "${status}" "${output}"
  [ "${status}" -eq 1 ]
}

@test "stop-signal=non-opt - unknown long option fails (1)" {
  run "${BIN_GETPARAMS}" --stop-signal=non-opt -- --foo

  print_result "${status}" "${output}"
  [ "${status}" -eq 1 ]
}

@test "stop-signal=unknown-opt - first non-opt stops parsing (0)" {
  run "${BIN_GETPARAMS}" --stop-signal=unknown-opt --shortopts=abc -- \
    -a -b foo -c
  
  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a -b -- 'foo' '-c'" ]
}

@test "stop-signal=unknown-opt - unknown short option stops parsing (0)" {
  run "${BIN_GETPARAMS}" --stop-signal=unknown-opt --shortopts=abd -- \
    -a -b -c -d
  
  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a -b -- '-c' '-d'" ]
}

@test "stop-signal=unknown-opt - unknown short option in group stops parsing (0)" {
  run "${BIN_GETPARAMS}" --stop-signal=unknown-opt --shortopts=abd -- -abcd

  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = " -- '-abcd'" ]
}

@test "stop-signal=unknown-opt - unknown long option stops parsing (0)" {
  run "${BIN_GETPARAMS}" --stop-signal=unknown-opt --shortopts=abc -- \
    -a -b --foo -c
  
  print_result "${status}" "${output}"
  [ "${status}" -eq 0 ]
  [ "${output}" = "-a -b -- '--foo' '-c'" ]
}

# vim: expandtab:ts=2:sw=0
