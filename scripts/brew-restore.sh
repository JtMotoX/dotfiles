#!/bin/sh

set -e
cd "$(dirname "$0")"

cd ..

brewfile="configs/brewfile"

brewfile="$(cd "$(dirname "${brewfile}")" && pwd)/$(basename "${brewfile}")"

brew bundle install --file="${brewfile}" --no-lock | grep -v '^Using '
