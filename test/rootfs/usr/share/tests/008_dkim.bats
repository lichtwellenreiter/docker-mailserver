#!/usr/bin/env bats

@test "check DKIM selector map exists" {
    [ -r /media/dkim/dkim_selectors.map ]
}

@test "check DKIM key for thievent.org exists" {
    [ -r /media/dkim/thievent.org.1337.key ]
}
