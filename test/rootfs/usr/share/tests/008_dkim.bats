#!/usr/bin/env bats

@test "check DKIM selector map exists" {
    [ -r /media/dkim/dkim_selectors.map ]
}

@test "check DKIM key for flind.ch exists" {
    [ -r /media/dkim/flind.ch.1337.key ]
}
