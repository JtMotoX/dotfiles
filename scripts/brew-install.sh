#!/bin/sh

set -e
cd "$(dirname "$0")"

# CHECK IF BREW INSTALLED
if command -v brew >/dev/null 2>&1; then
	echo "brew is already installed"
	exit 0
fi

# INSTALL BREW
echo "Installing brew"
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Finished brew install"
