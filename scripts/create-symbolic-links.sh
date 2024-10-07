#!/bin/sh

set -e
cd "$(dirname "$0")"
cd ../configs

# Parse command line arguments
while [ $# -gt 0 ]; do
	case "$1" in
		--override)
			OVERRIDE=true
			shift
			;;
		--help)
			echo "Usage: $0 [--override]"
			exit 0
			;;
		*)
			break
			;;
	esac
done

changes_made="false"

# Check if the link already exists and prompt for override if necessary
check_create_needed() {
	[ "$(readlink -f $1)" = "$(readlink -f $2)" ] && { return 0; }
	test -f "$2" || { rm -f "$2"; return 1; }
	echo "'$2' already exists."
	if [ "${OVERRIDE}" = true ]; then
		echo "Replacing '$2' since --override was specified"
		rm -f "$2"
		return 1
	fi
	while true; do
		read -p "Do you want to replace this with '$1'? [y/n]" yn
		case $yn in
			[Yy]* ) rm -f "$2"; return 1;;
			[Nn]* ) echo "Skipping '$1'"; return 0;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

# Create symbolic link
create_link() {
	check_create_needed "$1" "$2" && { return 0; }
	echo "Creating link: '$1' -> '$2'"
	if [ ! -d "$(dirname "$1")" ]; then
		echo "Directory not found for: $1"
		return
	fi
	if [ ! -d "$(dirname "$2")" ]; then
		mkdir -p "$(dirname "$2")"
	fi
	SRC="$(cd "$(dirname "$1")" && printf $(pwd) && printf "/$(basename "$1")")"
	DST="$(cd "$(dirname "$2")" && printf $(pwd) && printf "/$(basename "$2")")"
	SRC_RELATIVE="$(echo "${SRC}" | sed "s|^$(dirname "${DST}")||")"
	if [ "${SRC_RELATIVE}" != "${SRC}" ]; then
		SRC_RELATIVE=".${SRC_RELATIVE}"
		SRC="${SRC_RELATIVE}"
	fi
	ln -s "${SRC}" "$2"
	changes_made="true"
}

create_link ansible.cfg ~/.ansible.cfg
create_link ansible.cfg.sh ~/.ansible.cfg.sh
create_link bash_profile_custom ~/.bash_profile_custom
create_link p10k.zsh ~/.p10k.zsh
create_link sh_profile_custom ~/.sh_profile_custom
create_link screen_profile ~/.screen_profile
create_link screenrc ~/.screenrc
create_link tmux_profile ~/.tmux_profile
create_link tmux.conf ~/.tmux.conf
create_link zshrc ~/.zshrc
create_link vimrc ~/.vimrc
create_link Microsoft.PowerShell_profile.ps1 ~/.config/powershell/Microsoft.PowerShell_profile.ps1

if [ "${changes_made}" = "false" ]; then
	echo "All symbolic links are already created. No changes made."
fi
