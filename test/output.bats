#!/usr/bin/env bats

load '../tools/bats-support/load.bash'
load '../tools/bats-assert/load.bash'

readonly GETPARAMS="${BATS_TEST_DIRNAME%/*}/bin/getparams"

@test "output: embedded single quotes are escaped (0)" {
  run "${GETPARAMS}" --shortopts=a:b:c:: --longopts=foo:,bar:: -- \
    "wouldn't" -a "should've" -bCOULD\'VE \
    -c"would've" --foo "shouldn't" --bar="couldn't"
  assert_success
  
  assert_output "-a 'should'\''ve' -b 'COULD'\''VE' -c 'would'\''ve' \
--foo 'shouldn'\''t' --bar 'couldn'\''t' -- 'wouldn'\''t'"
}

@test "output: --keep-order: non-option parameters are output where they were found [--keep-order] (0)" {
  run "${GETPARAMS}" --keep-order --shortopts=abc -- -a FOO -b BAR -c
  assert_success
  assert_output "-a 'FOO' -b 'BAR' -c -- "
}

@test "output: --no-keep-order: non-option parameters are grouped at the end of output (0)" {
  run "${GETPARAMS}" --no-keep-order --shortopts=abc -- -a FOO -b BAR -c
  assert_success
  assert_output "-a -b -c -- 'FOO' 'BAR'"
}

@test "output: --combine-args: output options and their arguments as combined parameter (0)" {
  run "${GETPARAMS}" --combine-args --shortopts=a:b:: --longopts=foo:,bar:: -- \
    -a FLIM -bFLAM --foo FIZZ --bar=BUZZ
  assert_success
  assert_output "-a='FLIM' -b='FLAM' --foo='FIZZ' --bar='BUZZ' -- "
}

@test "output: --combine-args: unspecified and empty optional arguments are differentiated (0)" {
  run "${GETPARAMS}" --combine-args --longopts=foo:: -- --foo --foo=
  assert_success
  assert_output "--foo --foo='' -- "
}

@test "output: --no-combine-args: output options and their arguments as separate parameters (0)" {
  run "${GETPARAMS}" --no-combine-args --shortopts=a:b:: --longopts=foo:,bar:: -- \
    -a FLIM -bFLAM --foo FIZZ --bar=BUZZ
  assert_success
  assert_output "-a 'FLIM' -b 'FLAM' --foo 'FIZZ' --bar 'BUZZ' -- "
}

# vim: expandtab:ts=2:sw=0
