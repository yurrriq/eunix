#! /usr/bin/env bats

check ()
{
    diff <("$@") <(env PATH=bin "$@")
}


### echo ###

@test "echo a simple test" {
    check echo a simple test
}

@test "echo -n dash n" {
    check echo -n dash n
}

@test "echo -x ignore unknown options" {
    check echo -x ignore unknown options
}

@test "echo -n -x known then unknown" {
    check echo -n -x known then unknown
}

@test "echo -x -n unknown then known" {
    check echo -x -n unknown then known
}


### whoami ###

@test "whoami" {
    check whoami
}

@test "whoami -x ignore unknown options" {
    check whoami -x ignore unknown options
}
