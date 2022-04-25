#!/bin/sh

cd "$(dirname "$0")"

check_create_needed() {
	[ "$(readlink -f $1)" = "$(readlink -f $2)" ] && { echo "'$1' is already linked"; return 0; }
	test -f "$2" || { rm -f "$2"; return 1; }
	echo "'$2' already exsits."
	while true; do
		read -p "Do you want to replace this with '$1'? [y/n]" yn
		case $yn in
			[Yy]* ) rm -f "$2"; return 1;;
			[Nn]* ) echo "Skipping '$1'"; return 0;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

create_link() {
	echo
	check_create_needed "$1" "$2" && { return 0; }
	echo "Creating link: '$1' -> '$2'"
	RELATIVE_TARGET="$(realpath --relative-to="$(dirname $2)" "$(readlink -f $1)")"
	ln -s "${RELATIVE_TARGET}" "$2"
}

create_link ansible.cfg ~/.ansible.cfg
create_link bash_profile_custom ~/.bash_profile_custom
create_link p10k.zsh ~/.p10k.zsh
create_link sh_profile_custom ~/.sh_profile_custom
create_link tmux.conf ~/.tmux.conf
create_link zshrc ~/.zshrc
