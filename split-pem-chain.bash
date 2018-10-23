#!/usr/bin/env bash

# The OpenSSL CLI, generally speaking, does not handle chains of
# certificates very well. Several operations will look at the first
# certificate in a file and then stop processing. This is really
# insidious behavior since it's not often obvious that this is an
# error.
#
# This script attempts to split out a single file into many and
# currently works only on the PEM format.

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

certfile="$1"

