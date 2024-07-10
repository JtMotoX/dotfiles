#!/bin/sh

set -e
cd "$(dirname "$0")"

# CHECK IF macOS
if [ "$(uname)" != "Darwin" ]; then
	echo "This is not macOS"
	exit 1
fi

# CHECK IF BREW INSTALLED
if command -v brew >/dev/null 2>&1; then
	echo "brew is already installed"
	exit 0
fi

# INSTALL BREW
echo "Installing brew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval "$(/opt/homebrew/bin/brew shellenv)"

echo "Finished brew install"
