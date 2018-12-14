#!/usr/bin/env bash

base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd -P )"

source "$base_dir"/common.bash

root_ca_csr="$(mktemp rootcsr.XXXXXX)"
sub_ca_csr="$(mktemp subcsr.XXXXXX)"

trap_exit() {
    exit_status="$?"
    rm -rf "$root_ca_csr" "$sub_ca_csr"
    if [ $exit_status -ne 0 ]; then
        errmsg 'Something went wrong during execution.'
        errmsg 'Exit status was: '"$exit_status"
    fi
}
trap trap_exit EXIT

create_root_ca_csr() {
    openssl req \
            -new \
            -subj / \
            -config "$root_ini" \
            -out "$root_ca_csr" \
            -passout 'pass:asdf' \
            -keyout "$root_private_key"
}

create_sub_ca_csr() {
    openssl req \
            -new \
            -subj / \
            -config "$sub_ini" \
            -out "$sub_ca_csr" \
            -passout 'pass:asdf' \
            -keyout "$sub_private_key"
}

self_sign_root_ca() {
    openssl ca \
            -batch \
            -selfsign \
            -config "$root_ini" \
            -in "$root_ca_csr" \
            -out "$root_cert" \
            -passin 'pass:asdf' \
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
            -batch \
            -config "$root_ini" \
            -in "$sub_ca_csr" \
            -out "$sub_cert" \
            -passin 'pass:asdf' \
            -extensions sub_ca_ext
}

populate_templates() {
    cp "$ca_ini_template" "$root_ini"
    sed --in-place \
        -e 's:@@name@@:'"$root_name"':' \
        -e 's:@@home@@:'"$root_ca_dir"':' \
        -e 's:@@ocsp_portnum@@:'"9080"':' \
        -e 's:@@req_extensions@@:'"ca_ext"':' \
        -e 's:@@copy_extensions@@:'"none"':' \
        -e 's:@@default_crl_days@@:'"365"':' \
        -e 's:@@root_alt_name@@:'"rootca.com"':' \
        -e 's:@@sub_alt_name@@:'"subca.com"':' \
        -e 's:@@client_alt_name@@:'"client.com"':' \
        -e 's:@@rand_serial@@:'""':' \
        "$root_ini"

    cp "$ca_ini_template" "$sub_ini"
    sed --in-place \
        -e 's:@@name@@:'"$sub_name"':' \
        -e 's:@@home@@:'"$sub_ca_dir"':' \
        -e 's:@@ocsp_portnum@@:'"9081"':' \
        -e 's:@@req_extensions@@:'"sub_ca_ext"':' \
        -e 's:@@copy_extensions@@:'"copy"':' \
        -e 's:@@default_crl_days@@:'"30"':' \
        -e 's:@@root_alt_name@@:'"rootca.com"':' \
        -e 's:@@sub_alt_name@@:'"subca.com"':' \
        -e 's:@@client_alt_name@@:'"client.com"':' \
        -e 's:@@rand_serial@@:'""':' \
        "$sub_ini"

    cp "$ca_ini_template" "$client_ini"
    sed --in-place \
        -e 's:@@name@@:'"$sub_name"':' \
        -e 's:@@home@@:'"$sub_ca_dir"':' \
        -e 's:@@ocsp_portnum@@:'"9081"':' \
        -e 's:@@req_extensions@@:'"sub_ca_ext"':' \
        -e 's:@@copy_extensions@@:'"copy"':' \
        -e 's:@@default_crl_days@@:'"30"':' \
        -e 's:@@root_alt_name@@:'"rootca.com"':' \
        -e 's:@@sub_alt_name@@:'"subca.com"':' \
        -e 's:@@client_alt_name@@:'"client.com"':' \
        -e 's:@@rand_serial@@:'"rand_serial = no"':' \
        "$client_ini"
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

    touch "$root_db_dir"/index "$sub_db_dir"/index "$root_db_dir"/index.attr "$sub_db_dir"/index.attr
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
