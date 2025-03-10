#!/usr/bin/env bats

@test "check mailhog api for messages" {
    if [ ${RELAYHOST} = "false" ]; then
        echo '# Relayhost is disabled, skipping test' >&3
        skip
    fi

    run curl "http://mailhog:8025/api/v2/messages"
    [ "$status" -eq 0 ]
}

@test "send mail to mda with smtp authentification, external recipient" {
    if [ ${RELAYHOST} = "false" ]; then
        echo '# Relayhost is disabled, skipping test' >&3
        skip
    fi

    run swaks -s mda --port 587 --to nobody@ressourcenkonflikt.de --from admin@flind.ch -a -au admin@flind.ch -ap aequ4Ayais -tls --body "$BATS_TEST_DESCRIPTION"
    [ "$status" -eq 0 ]
}

@test "check mailhog api for outgoing message" {
    if [ ${RELAYHOST} = "false" ]; then
        echo '# Relayhost is disabled, skipping test' >&3
        skip
    fi

    sleep 5 # Give mailhog some time

    RESULT=$(curl -s "http://mailhog:8025/api/v2/messages" | jq -cr .items[0].Content.Body | tr -d '[:space:]')

    [ "$RESULT" = "sendmailtomdawithsmtpauthentification,externalrecipient" ]
}
