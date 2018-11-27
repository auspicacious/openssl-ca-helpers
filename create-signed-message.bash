#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

textfile="$1"
signing_cert="$2"
signing_private_key="$3"

# https://stackoverflow.com/questions/35443847/how-to-create-detached-cms-signature

write_passphrase() {
    pass private/ca/openvpn/client
}

write_passphrase \
    | openssl cms \
        -in "$textfile" \
        -inkey "$signing_private_key" \
        -out "$textfile".smime \
        -outform SMIME \
        -passin stdin \
        -sign \
        -signer "$signing_cert"

write_passphrase \
    | openssl cms \
        -in "$textfile" \
        -inkey "$signing_private_key" \
        -out "$textfile".pem \
        -outform PEM \
        -passin stdin \
        -sign \
        -signer "$signing_cert"

write_passphrase \
    | openssl cms \
        -in "$textfile" \
        -inkey "$signing_private_key" \
        -out "$textfile".der \
        -outform DER \
        -passin stdin \
        -sign \
        -signer "$signing_cert"

write_passphrase \
    | openssl cms \
        -cmsout \
        -in "$textfile" \
        -inkey "$signing_private_key" \
        -out "$textfile".cmsout \
        -passin stdin \
        -sign \
        -signer "$signing_cert"
