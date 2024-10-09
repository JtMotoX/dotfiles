#!/bin/sh

set -e
cd "$(dirname "$0")"

cd ..

brewfile="configs/brewfile"

brewfile="$(cd "$(dirname "${brewfile}")" && pwd)/$(basename "${brewfile}")"

# CREATE BUNDLE
brew tap Homebrew/bundle
brew bundle dump --force --no-vscode --file="/tmp/brewfile"

# REMOVE SOME LINES FROM THE BUNDLE
sed -i '' '/^tap "homebrew\/cask-versions"$/d' "${brewfile}"
sed -i '' '/^tap "homebrew\/bundle"$/d' "${brewfile}"

# SORT THE BUNDLE WITH TAP AT THE TOP
(grep '^tap ' "/tmp/brewfile" | sort; grep -v '^tap ' "/tmp/brewfile" | sort) > "/tmp/brewfile_sorted"

# MOVE CASK ENTRIES TO MAC FILE
if [ "$(uname)" = "Darwin" ]; then
    grep -E '^(cask|tap) ' /tmp/brewfile_sorted >"${brewfile}-mac"
    sed -i '' '/^cask /d' /tmp/brewfile_sorted
fi

# MOVE REMAINING ENTRIES TO GENERIC FILE
mv /tmp/brewfile_sorted "${brewfile}"


echo "Successfully backed up brew packages to '${brewfile}'"
