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
DCOMP_BIN_FILE="${HOME}/.local/bin/dcomp"
if [ -f "${DCOMP_BIN_FILE}" ]; then
	rm "${DCOMP_BIN_FILE}"
fi
mkdir -p "$(dirname "${DCOMP_BIN_FILE}")"
ln -s "${DCOMP_DIR}/dcomp.sh" "${DCOMP_BIN_FILE}"
export PATH="$(dirname "${DCOMP_BIN_FILE}"):${PATH}"

# CHECK IF THE INSTALLATION WAS SUCCESSFUL
if ! command -v dcomp >/dev/null 2>&1; then
	echo "dcomp failed to install."
	exit 1
fi

echo "dcomp installed successfully."
