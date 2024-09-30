#!/bin/sh

set -e
cd "$(dirname "$0")"

cd ..

install_brewfile() {
	echo "Installing $1..."
	brewfile_realpath="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
	brew bundle install --file="${brewfile_realpath}" --no-lock | grep -v '^Using '
}

install_brewfile "configs/brewfile"
if [ "$(uname)" = "Darwin" ]; then install_brewfile "configs/brewfile-mac"; fi
if [ "$(uname)" = "Linux" ]; then install_brewfile "configs/brewfile-linux"; fi
