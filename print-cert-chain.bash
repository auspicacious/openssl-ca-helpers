#!/usr/bin/env bash

# TODO interesting idea here to use the builtin SSL server to do chain
# validation, since it's hard to do with verify:
# https://gist.github.com/hilbix/bde7c02009544faed7a1

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

certfile="$1"

openssl x509 -in "$certfile" -noout -text
