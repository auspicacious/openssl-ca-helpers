#!/usr/bin/env bash

# Note that this doesn't verify the signature.

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

message="$1"

openssl cms \
        -in "$message" \
        -inform PEM \
        -verify \
        -certfile certs/client.cert.pem \
        -CAfile <(cat ../certs/ca.cert.pem certs/intermediate.cert.pem)
