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

if ! command -v dash >/dev/null 2>&1; then
	echo "Could not find 'dash'"
	exit 1
fi

# CHECK IF MACOS VERSION IS SUPPORTED
if [ "$(uname)" = "Darwin" ]; then
	# CHECK MACOS VERSION SINCE DASH WAS NOT INTRODUCED UNTIL CATALINA
	macos_version="$(sw_vers -productVersion)"
	macos_major_version="$(echo "${macos_version}" | cut -d. -f1)"
	macos_minor_version="$(echo "${macos_version}" | cut -d. -f2)"
	if [ "${macos_major_version}" -lt 10 ] || ( [ "${macos_major_version}" -eq 10 ] && [ "${macos_minor_version}" -lt 15 ] ); then
		echo "MacOS version 10.15 and later is supported"
		echo "You are using ${macos_version}"
		exit 1
	fi
	# SWITCH TO BUILT-IN MACOS DASH
	echo "Setting sh to dash"
	sudo ln -sf /bin/dash /var/select/sh
else
	# SWITCH TO DASH
	echo "Setting sh to $(basename "$(command -v dash)")"
	sh_path=$(command -v sh)
	sudo touch "$(dirname "${sh_path}")/test" && sudo rm -f "$(dirname "${sh_path}")/test"
	if [ -f "${sh_path}.bak" ]; then
		sudo rm -f "${sh_path}"
	fi
	sudo mv "${sh_path}" "${sh_path}.bak"
	sudo ln -s "$(command -v dash)" "${sh_path}"
fi

# MAKE SURE THAT SH IS NOW BOURNE SHELL
if ! is_bourne_shell; then
	echo "Failed to set bourne shell"
	exit 1
fi

echo "Successfully installed bourne shell"
