#!/bin/sh

set -e
cd "$(dirname "$0")"

# GET THE GIT DIRECTORY WHERE THE ZSHRC LIVES
dotfiles_dir="$(git rev-parse --show-toplevel 2>/dev/null)"

# CHECK IF THE DIRECTORY WHERE THE ZSHRC LIVES IS MY GIT REPO
if [ "${dotfiles_dir}" != '' ] && git -C "${dotfiles_dir}" remote get-url origin 2>/dev/null | grep 'JtMotoX\/dotfiles' >/dev/null 2>&1; then
    # git -C "${dotfiles_dir}" reset --hard HEAD~1 >/dev/null # JUST FOR TESTING

	# FETCH THE REMOTE
	git -C "${dotfiles_dir}" fetch origin >/dev/null 2>&1

	# CHECK IF OUR LOCAL IS BEHIND THE REMOTE
    if git -C "${dotfiles_dir}" status -uno 2>/dev/null | grep 'Your branch is behind' >/dev/null 2>&1; then
        echo "There are updates for $(basename "${dotfiles_dir}")"
        echo "Updating $(basename "${dotfiles_dir}") . . ."
        git -C "${dotfiles_dir}" pull
		echo "You will need to restart your session for the changes to take effect."
    fi
fi
