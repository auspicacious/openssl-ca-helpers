#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# Reference https://www.feistyduck.com/library/openssl-cookbook/

base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd -P )"
source "$base_dir"/common.bash

client_csr="$(mktemp clientcsr.XXXXXX)"

trap_exit() {
    exit_status="$?"
    rm -rf "$client_csr"
    if [ $exit_status -ne 0 ]; then
        errmsg 'Something went wrong during execution.'
        errmsg 'Exit status was: '"$exit_status"
    fi
}
trap trap_exit EXIT

create_csr() {
    openssl req \
            -new \
            -subj / \
            -config "$client_ini" \
            -out "$client_csr" \
            -passout 'pass:asdf' \
            -keyout "$client_private_key"
}

sign_csr() {
    openssl ca \
            -config "$sub_ini" \
            -in "$client_csr" \
            -out "$client_cert" \
            -passin 'pass:asdf' \
            -extensions client_ext
}

create_csr
sign_csr
