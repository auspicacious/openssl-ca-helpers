#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# Reference https://www.feistyduck.com/library/openssl-cookbook/

root_name="akmanrootca1"
sub_name="akmansubca1"

base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd -P )"
ca_ini_template="$base_dir"/ca.template.ini

out_dir="$base_dir"/out

root_ca_dir="$out_dir"/root-ca
root_certs_dir="$root_ca_dir"/certs
root_db_dir="$root_ca_dir"/db
root_private_dir="$root_ca_dir"/private

root_private_key="$root_private_dir"/"$root_name".key
root_cert="$root_certs_dir"/"$root_name".crt
root_ini="$root_ca_dir"/root-ca.ini

sub_ca_dir="$out_dir"/sub-ca
sub_certs_dir="$sub_ca_dir"/certs
sub_db_dir="$sub_ca_dir"/db
sub_private_dir="$sub_ca_dir"/private

sub_private_key="$sub_private_dir"/"$sub_name".key
vsub_cert="$sub_certs_dir"/"$sub_name".crt
sub_ini="$sub_ca_dir"/sub-ca.ini

root_ca_csr="$(mktemp rootcsr.XXXXXX)"
sub_ca_csr="$(mktemp subcsr.XXXXXX)"

errmsg() {
    local IFS=' '
    printf '%s\n' "$*" 1>&2
}

trap_exit() {
    exit_status="$?"
    rm -rf "$root_ca_csr" "$sub_ca_csr"
    if [ $exit_status -ne 0 ]; then
        errmsg 'Something went wrong during execution.'
        errmsg 'Exit status was: '"$exit_status"
    fi
}
trap EXIT trap_exit

create_root_ca_csr() {
    openssl req \
            -new \
            -config "$root_ini" \
            -out "$root_ca_csr" \
            -keyout "$root_private_key"
}

create_sub_ca_csr() {
    openssl req \
            -new \
            -config "$sub_ini" \
            -out "$sub_ca_csr" \
            -keyout "$sub_private_key"
}

self_sign_root_ca() {
    openssl ca \
            -selfsign \
            -config "$root_ini" \
            -in "$root_ca_csr" \
            -out "$root_cert" \
            -extensions ca_ext
}

generate_crl() {
    openssl ca \
            -gencrl \
            -config "$root_ini" \
            -out root-ca.crl
}

sign_sub_ca() {
    openssl ca \
            -config "$root_ini" \
            -in "$sub_ca_csr" \
            -out "$sub_cert" \
            -extensions sub_ca_ext
}

populate_templates() {
    cp "$ca_ini_template" "$root_ini"
    sed --in-place \
        -e 's:@@name@@:'"$root_name"':' \
        -e 's:@@home@@:'"$root_ca_dir"':' \
        -e 's:@@ocsp_portnum@@:'"9080"':' \
        -e 's:@@copy_extensions@@:'"none"':' \
        -e 's:@@default_crl_days@@:'"365"':' \
        "$root_ini"

    cp "$ca_ini_template" "$sub_ini"
    sed --in-place \
        -e 's:@@name@@:'"$sub_name"':' \
        -e 's:@@home@@:'"$sub_ca_dir"':' \
        -e 's:@@ocsp_portnum@@:'"9081"':' \
        -e 's:@@copy_extensions@@:'"copy"':' \
        -e 's:@@default_crl_days@@:'"30"':' \
        "$sub_ini"
}

make_ca_dirs() {
    mkdir \
        "$out_dir" \
        "$root_ca_dir" \
        "$root_certs_dir" \
        "$root_db_dir" \
        "$sub_ca_dir" \
        "$sub_certs_dir" \
        "$sub_db_dir"
    mkdir --mode=700 \
          "$root_private_dir" \
          "$sub_private_dir"

    touch "$root_db_dir"/index "$sub_db_dir"/index
    openssl rand -hex 16 > "$root_db_dir"/serial
    openssl rand -hex 16 > "$sub_db_dir"/serial
    printf '%s\n' '1001' > "$root_db_dir"/crlnumber
    printf '%s\n' '1001' > "$sub_db_dir"/crlnumber
}

make_ca_dirs
populate_templates
create_root_ca_csr
self_sign_root_ca
create_sub_ca_csr
sign_sub_ca
