#!/bin/sh

set -e
cd "$(dirname "$0")"

cd ..

brewfile="configs/brewfile"

brewfile="$(cd "$(dirname "${brewfile}")" && pwd)/$(basename "${brewfile}")"

brew tap Homebrew/bundle
brew bundle dump --force --file="${brewfile}"
sed -i '/^vscode /d' "${brewfile}"
sed -i '/^tap "homebrew\/cask-versions"$/d' "${brewfile}"

echo "Successfully backed up brew packages to '${brewfile}'"
