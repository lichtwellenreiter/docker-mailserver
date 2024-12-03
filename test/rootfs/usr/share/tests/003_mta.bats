#!/usr/bin/env bats

@test "send mail to local account address" {
    run swaks -s mta --to admin@flind.ch --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 0 ]
}

@test "send mail to local address with extension" {
    run swaks -s mta --to admin-test@flind.ch --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 0 ]
}

@test "authentification on smtp with disabled account should fail" {
    run swaks -s mta --to admin@flind.ch --from disabled@flind.ch -a -au disabled@flind.ch -ap test1234 -tls --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 28 ]
}

@test "authentification on smtp with disabled and send only account should fail" {
    run swaks -s mta --to admin@flind.ch --from disabledsendonly@flind.ch -a -au disabled@flind.ch -ap test1234 -tls --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 28 ]
}

@test "send mail to mda with smtp authentification (submission service)" {
    run swaks -s mda --port 587 --to admin@flind.ch --from admin@flind.ch -a -au admin@flind.ch -ap aequ4Ayais -tls --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 0 ]
}

@test "send mail to mda with smtp authentification, with address extension (submission service)" {
    run swaks -s mda --port 587 --to admin@flind.ch --from admin-extension@flind.ch -a -au admin@flind.ch -ap aequ4Ayais -tls --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 0 ]
}

@test "send mail to mda from sendonly account with smtp authentification (submission service)" {
    run swaks -s mda --port 587 --to admin@flind.ch --from sendonly@flind.ch -a -au sendonly@flind.ch -ap test1234 -tls --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 0 ]
}

@test "send mail to local alias" {
    run swaks -s mta --to foo@flind.ch --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 0 ]
}

@test "send junk mail to local address" {
    run swaks -s mta --to admin@flind.ch --body "$BATS_TEST_DESCRIPTION" --header "X-Spam: Yes"
    [ "$status" -eq 0 ]
}

@test "send mail with too big attachment to quota user" {
    dd if=/dev/urandom of=/tmp/bigfile bs=1M count=5
    run swaks -s mta --to quota@flind.ch --body "$BATS_TEST_DESCRIPTION" --attach /tmp/bigfile
    [ "$status" -eq 0 ]
}

@test "send mail to disabled user" {
    run swaks -s mta --to disabled@flind.ch --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 0 ]
}

@test "maildir was created" {
    sleep 10 # MTA + MDA need some time. :)
    [ -d /var/vmail/flind.ch/admin/Maildir/new/ ]
}

@test "mail to local account address is stored" {
    run grep -r "send mail to local account address" /var/vmail/flind.ch/admin/Maildir/
    [ "$status" -eq 0 ]
}

@test "mail to local alias is stored" {
    run grep -r "send mail to local alias" /var/vmail/flind.ch/admin/Maildir/
    [ "$status" -eq 0 ]
}

@test "mail to local address with extension is stored" {
    run grep -r "send mail to local address with extension" /var/vmail/flind.ch/admin/Maildir/
    [ "$status" -eq 0 ]
}

@test "mail to mda with smtp authentification (submission service) is stored" {
    run grep -r "send mail to mda with smtp authentification (submission service)" /var/vmail/flind.ch/admin/Maildir/
    [ "$status" -eq 0 ]
}

@test "send mail to mda with smtp authentification, with address extension (submission service) is stored" {
    run grep -r "send mail to mda with smtp authentification, with address extension (submission service)" /var/vmail/flind.ch/admin/Maildir/
    [ "$status" -eq 0 ]
}

@test "send mail to mda from sendonly account with smtp authentification (submission service) is stored" {
    run grep -r "send mail to mda from sendonly account with smtp authentification (submission service)" /var/vmail/flind.ch/admin/Maildir/
    [ "$status" -eq 0 ]
}

@test "junk mail is assorted to the junk folder" {
    run grep -r "send junk mail to local address" /var/vmail/flind.ch/admin/Maildir/.Junk/
    [ "$status" -eq 0 ]
}

@test "mail with too big attachment is not found" {
    run grep -r "send mail with too big attachment to quota user" /var/vmail/flind.ch/quota/Maildir/
    [ "$status" -ne 0 ]
}

@test "mail to disabled user is stored anyway" {
    run grep -r "send mail to disabled user" /var/vmail/flind.ch/disabled/Maildir/
    [ "$status" -eq 0 ]
}

@test "send gtube mail is rejected" {
    run swaks -s mta --to admin@flind.ch --data /usr/share/fixtures/gtube.txt
    [ "$status" -eq 26 ]
}

@test "mail to send only mailbox is rejected" {
    run swaks -s mta --to sendonly@flind.ch --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 24 ]
}

@test "mail to disabled and send only mailbox is rejected anyway" {
    run swaks -s mta --to disabledsendonly@flind.ch --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 24 ]
}

@test "virus is rejected" {
    if [ ${FILTER_VIRUS} = "false" ]; then
        skip
    fi

    run swaks -s mta --to admin@flind.ch --attach - < /usr/share/fixtures/eicar.com
    [ "$status" -eq 26 ]
}
