#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

# Reference https://www.feistyduck.com/library/openssl-cookbook/

root_name="akmanrootca1"
sub_name="akmansubca1"
client_name="akmanclient1"

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
sub_cert="$sub_certs_dir"/"$sub_name".crt
sub_ini="$sub_ca_dir"/sub-ca.ini

client_private_key="$sub_private_dir"/"$client_name".key
client_cert="$sub_certs_dir"/"$client_name".crt
client_ini="$sub_ca_dir"/client-ca.ini

errmsg() {
    local IFS=' '
    printf '%s\n' "$*" 1>&2
}
