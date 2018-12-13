#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# Reference https://www.feistyduck.com/library/openssl-cookbook/

client_name="akmanclient1"
base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd -P )"


generate_csr() {
    openssl req \
            -new \
            -config fd.cnf \
            -key fd.key \
            -out fd.csr
}

sign_csr() {
    openssl ca \
            -config sub-ca.ini \
            -in client.csr \
            -out client.crt \
            -extensions client_ext
}
