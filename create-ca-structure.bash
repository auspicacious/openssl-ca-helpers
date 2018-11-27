#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# Reference https://www.feistyduck.com/library/openssl-cookbook/

create_root_ca_csr() {
    openssl req \
            -new \
            -config root-ca.ini \
            -out root-ca.csr \
            -keyout private/root-ca.key
}

create_sub_ca_csr() {
    openssl req \
            -new \
            -config sub-ca.ini \
            -out sub-ca.csr \
            -keyout private/sub-ca.key
}

self_sign_root_ca() {
    openssl ca \
            -selfsign \
            -config root-ca.ini \
            -in root-ca.csr \
            -out root-ca.crt \
            -extensions ca_ext
}

generate_crl() {
    openssl ca \
            -gencrl \
            -config root-ca.ini \
            -out root-ca.crl
}

sign_sub_ca() {
    openssl ca \
            -config root-ca.ini \
            -in sub-ca.csr \
            -out sub-ca.crt \
            -extensions sub_ca_ext
}

make_ca_dirs() {
    mkdir -p \
          root-ca/certs \
          root-ca/db \
          root-ca/private \
          sub-ca/certs \
          sub-ca/db \
          sub-ca/private
    chmod 700 root-ca/private sub-ca/private
    touch root-ca/db/index sub-ca/db/index
    openssl rand -hex 16 > root-ca/db/serial
    openssl rand -hex 16 > sub-ca/db/serial
    printf '%s\n' '1001' > root-ca/db/crlnumber
    printf '%s\n' '1001' > sub-ca/db/crlnumber
}

make_ca_dirs
create_root_ca_csr
self_sign_root_ca
create_sub_ca_csr
sign_sub_ca
