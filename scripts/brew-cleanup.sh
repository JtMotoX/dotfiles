#!/bin/sh

set -e
cd "$(dirname "$0")"

cd ..

brewfile="configs/brewfile"

brewfile="$(cd "$(dirname "${brewfile}")" && pwd)/$(basename "${brewfile}")"

brew bundle cleanup --file="${brewfile}" | grep -v 'to make these changes'

echo "Would you like to remove unused formulae? (y/n)"
read -r response
if [ "$response" != "y" ]; then
	echo "Skipping removal of unused formulae"
	exit 0
fi

brew bundle cleanup --file="${brewfile}" --force
echo "Removed unused formulae"
