#!/bin/sh

set -e
cd "$(dirname "$0")"

DCOMP_DIR="${HOME}/.dcomp"

# CLONE OR UPDATE THE REPO
if [ -d "${DCOMP_DIR}" ]; then
	echo "Updating dcomp . . ."
    git -C "${DCOMP_DIR}" pull
else
	echo "Cloning dcomp . . ."
	git clone https://github.com/JtMotoX/docker-compose-wrapper.git "${DCOMP_DIR}"
fi

# CREATE SYMLINK
if [ -f "${HOME}/.local/bin/dcomp" ]; then
	rm "${HOME}/.local/bin/dcomp"
fi
ln -s "${DCOMP_DIR}/dcomp.sh" "${HOME}/.local/bin/dcomp"

# CHECK IF THE INSTALLATION WAS SUCCESSFUL
if ! command -v dcomp >/dev/null 2>&1; then
	echo "dcomp failed to install."
	exit 1
fi

echo "dcomp installed successfully."
