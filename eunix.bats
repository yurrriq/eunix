#! /usr/bin/env bats


### echo ###

check_echo ()
{
    diff <(echo $@) <(env PATH=bin echo $@)
}

@test "echo a simple test" {
    check_echo a simple test
}

@test "echo -n dash n" {
    check_echo -n dash n
}

@test "echo -x ignore unknown options" {
    check_echo -x ignore unknown options
}

@test "echo -n -x known then unknown" {
    check_echo -n -x known then unknown
}

@test "echo -x -n unknown then known" {
    check_echo -x -n unknown then known
}


### whoami ###

check_whoami ()
{
    diff <(whoami $@ 2>&1 | head -n1) <(env PATH=bin whoami $@ 2>&1 | head -n1)
}

@test "whoami" {
    check_whoami
}

@test "whoami -x ignore unknown options" {
    check_whoami -x ignore unknown options
}
