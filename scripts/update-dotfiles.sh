#!/bin/sh

set -e
cd "$(dirname "$0")"

# EXIT IF WE ALREADY CHECKED TODAY
if [ -f /tmp/.dotfilesupdatecheck ] && [ "$(( $(date +%s) - $(date -r /tmp/.dotfilesupdatecheck +%s) ))" -lt 86400 ]; then
    exit 0
fi
touch /tmp/.dotfilesupdatecheck

# GET THE GIT DIRECTORY WHERE THE ZSHRC LIVES
dotfiles_dir="$(git rev-parse --show-toplevel 2>/dev/null)"

# CHECK IF THE DIRECTORY WHERE THE ZSHRC LIVES IS MY GIT REPO
if [ "${dotfiles_dir}" = '' ] || ! git -C "${dotfiles_dir}" remote get-url origin 2>/dev/null | grep 'JtMotoX\/dotfiles' >/dev/null 2>&1; then
    exit 0
fi

# git -C "${dotfiles_dir}" reset --hard HEAD~1 >/dev/null # JUST FOR TESTING

# FETCH THE REMOTE
git -C "${dotfiles_dir}" fetch origin >/dev/null 2>&1

# CHECK IF OUR LOCAL IS BEHIND THE REMOTE
if ! git -C "${dotfiles_dir}" status -uno 2>/dev/null | grep 'Your branch is behind' >/dev/null 2>&1; then
    exit 0
fi

# UPDATE THE LOCAL
echo "There are updates for $(basename "${dotfiles_dir}")"
echo "Updating $(basename "${dotfiles_dir}") . . ."
git -C "${dotfiles_dir}" pull
setup_script="${dotfiles_dir}/setup.sh"
echo
echo "You will need to restart your session for some of the changes to take effect."
printf "After restarting your ssssion, it is recommended to run the setup script again"
if [ -f "${setup_script}" ]; then
    HOME="${HOME:=$(cd ~ && pwd)}"
    printf ":\n\t$( echo "${setup_script}" | sed "s|${HOME}|~|" )"
else
    printf "."
fi
printf "\n"
