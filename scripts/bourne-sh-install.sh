#!/bin/sh

set -e
cd "$(dirname "$0")"

# FUNCTION TO CHECK IF SH IS BOURNE SHELL
is_bourne_shell() {
	! sh -c 'a="a";echo ${a[@]}'>/dev/null 2>&1
}

# CHECK IF SH IS BOURNE SHELL
if is_bourne_shell; then
	echo "Bourne shell is already set"
	exit 0
fi

# INSTALL DASH
if ! command -v dash >/dev/null 2>&1; then
	echo "Installing dash"
	if command -v apt-get >/dev/null 2>&1; then
		sudo apt-get update && apt-get install -y dash
	elif command -v pacman >/dev/null 2>&1; then
		sudo pacman -S dash
	elif command -v dnf >/dev/null 2>&1; then
		sudo dnf install -y dash
	elif command -v brew >/dev/null 2>&1; then
		brew install dash
	elif command -v port >/dev/null 2>&1; then
		sudo port install dash dash-completions
	elif command -v zypper >/dev/null 2>&1; then
		sudo zypper install dash
	elif command -v yum >/dev/null 2>&1; then
		sudo yum install -y dash
	elif comand -v apk >/dev/null 2>&1; then
		sudo apk add dash
	else
		echo "Please install dash with your package manager"
		exit 1
	fi
fi

# SET SH TO DASH
echo "Setting sh to dash"
sh_path=$(command -v sh)
sudo rm -f "${sh_path}"
sudo ln -s $(which dash) "${sh_path}"

# MAKE SURE THAT SH IS NOW BOURNE SHELL
if ! is_bourne_shell; then
	echo "Failed to set bourne shell"
	exit 1
fi

echo "Successfully installed bourne shell"
