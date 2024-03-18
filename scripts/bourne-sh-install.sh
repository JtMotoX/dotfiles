#!/bin/sh

set -e
cd "$(dirname "$0")"

# FUNCTION TO CHECK IF SH IS BOURNE SHELL
is_bourne_shell() {
	! sh -c 'a="a";echo ${a[@]}'>/dev/null 2>&1
}

# FUNCTION TO INSTALL A PACKAGE IF NOT EXISTS ALREADY
install_package() {
    if ! command -v $1 >/dev/null 2>&1; then
        echo "Installing $1"
        if command -v apt-get >/dev/null 2>&1; then
            install_command="sudo apt-get update && sudo apt-get install -y "$1""
        elif command -v pacman >/dev/null 2>&1; then
            install_command="sudo pacman -Syu --noconfirm "$1""
        elif command -v dnf >/dev/null 2>&1; then
            install_command="sudo dnf install -y "$1""
        elif command -v brew >/dev/null 2>&1; then
            install_command="brew install "$1""
        elif command -v port >/dev/null 2>&1; then
            install_command="sudo port install "$1""
        elif command -v zypper >/dev/null 2>&1; then
            install_command="sudo zypper install "$1""
        elif command -v yum >/dev/null 2>&1; then
            install_command="sudo yum install -y "$1""
        elif command -v apk >/dev/null 2>&1; then
            install_command="sudo apk add "$1""
        else
            echo "Please install $1 with your package manager"
            exit 1
        fi
        if [ "${install_command}" != "" ]; then
            echo "Executing: ${install_command}"
            sh -c "${install_command}"
        fi
    fi
}

# FUNCTION TO CHECK IF REPLACEMENT SH EXISTS
get_replacement_sh() {
	if command -v dashf >/dev/null 2>&1; then
		replacement_sh_path="$(command -v dash)"
		return 0
	fi
	if command -v busybox >/dev/null 2>&1; then
		replacement_sh_path="$(command -v busybox)"
		return 0
	fi
	return 1
}

# CHECK IF SH IS BOURNE SHELL
if is_bourne_shell; then
	echo "Bourne shell is already set"
	exit 0
fi

# CHECK IF MACOS VERSION IS SUPPORTED
if [ "$(uname)" = "Darwin" ]; then
	# CHECK MACOS VERSION SINCE DASH WAS NOT INTRODUCED UNTIL CATALINA
	macos_version="$(sw_vers -productVersion)"
	macos_major_version="$(echo "${macos_version}" | cut -d. -f1)"
	macos_minor_version="$(echo "${macos_version}" | cut -d. -f2)"
	if [ "${macos_major_version}" -lt 10 ] || ( [ "${macos_major_version}" -eq 10 ] && [ "${macos_minor_version}" -lt 15 ] ); then
		echo "MacOS version 10.15.7 and later is supported"
		echo "You are using ${macos_version}"
		exit 1
	fi
	# SWITCH TO BUILT-IN MACOS DASH
	echo "Setting sh to dash"
	sudo ln -sf /bin/dash /var/select/sh
else
	# INSTALL REPLACEMENT SH IF NONE FOUND
	if ! get_replacement_sh; then
		install_package "dash" || install_package "busybox"
	fi
	if ! get_replacement_sh; then
		echo "Failed to install a replacement sh"
		exit 1
	fi
	echo "Setting sh to $(basename "${replacement_sh_path}")"
	sh_path=$(command -v sh)
	sudo touch "$(dirname "${sh_path}")/test" && sudo rm -f "$(dirname "${sh_path}")/test"
	if [ -f "${sh_path}.bak" ]; then
		sudo rm -f "${sh_path}"
	fi
	sudo mv "${sh_path}" "${sh_path}.bak"
	sudo ln -s "${replacement_sh_path}" "${sh_path}"
fi

# MAKE SURE THAT SH IS NOW BOURNE SHELL
if ! is_bourne_shell; then
	echo "Failed to set bourne shell"
	exit 1
fi

echo "Successfully installed bourne shell"
