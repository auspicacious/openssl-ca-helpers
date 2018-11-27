#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# Reference https://www.feistyduck.com/library/openssl-cookbook/

openssl req \
        -new \
        -config fd.cnf \
        -key fd.key \
        -out fd.csr

openssl ca \
    -config sub-ca.ini \
    -in client.csr \
    -out client.crt \
    -extensions client_ext
