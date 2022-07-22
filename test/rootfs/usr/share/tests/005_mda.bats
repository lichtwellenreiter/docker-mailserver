#!/usr/bin/env bats

@test "send mail to mda from disabled account with smtp authentification (submission service)" {
    run swaks -s mda --port 587 --to admin@thievent.org --from disabled@thievent.org -a -au disabled@thievent.org -ap test1234 -tls --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 28 ]
}

@test "send mail to mda without authentification (submission service)" {
    run swaks -s mda --port 587 --to admin@thievent.org --from disabled@thievent.org -tls --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 23 ]
}

@test "send mail to mda without tls (submission service)" {
    run swaks -s mda --port 587 --to admin@thievent.org --from admin@thievent.org -a -au admin@thievent.org -ap aequ4Ayais --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 28 ]
}

@test "count mails in inbox via imap" {
    run imap-tester test:count mda 143 admin@thievent.org aequ4Ayais INBOX
    [ "$output" -gt 3 ]
}

@test "count mails in inbox via imaps" {
    run imap-tester test:count mda 993 admin@thievent.org aequ4Ayais INBOX
    [ "$output" -gt 3 ]
}

@test "count mails in inbox via pop3" {
    run imap-tester test:count mda 110 admin@thievent.org aequ4Ayais INBOX
    [ "$output" -gt 3 ]
}

@test "count mails in inbox via pop3s" {
    run imap-tester test:count mda 995 admin@thievent.org aequ4Ayais INBOX
    [ "$output" -gt 3 ]
}

@test "imap login to send only mailbox is not possible" {
    run imap-tester test:count mda 143 sendonly@thievent.org test1234 INBOX
    [ "$status" -eq 1 ]
}

@test "pop3 login to send only mailbox is not possible" {
    run imap-tester test:count mda 110 sendonly@thievent.org test1234 INBOX
    [ "$status" -eq 1 ]
}

@test "pop3 login to quota mailbox is possible" {
    run imap-tester test:count mda 110 quota@thievent.org test1234 INBOX
    [ "$status" -eq 0 ]
}

@test "imap login to quota mailbox is possible" {
    run imap-tester test:count mda 143 quota@thievent.org test1234 INBOX
    [ "$status" -eq 0 ]
}

@test "pop3 login to disabled mailbox is not possible" {
    run imap-tester test:count mda 110 disabled@thievent.org test1234 INBOX
    [ "$status" -eq 1 ]
}

@test "imap login to disabled mailbox is not possible" {
    run imap-tester test:count mda 143 disabled@thievent.org test1234 INBOX
    [ "$status" -eq 1 ]
}

@test "mails are owned by vmail" {
    run find /var/vmail/thievent.org/ -not -user 5000
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}
