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
LOCAL_BIN_DIR="${HOME}/.local/bin"
DCOMP_BIN_FILE="${LOCAL_BIN_DIR}/dcomp"
if [ -f "${DCOMP_BIN_FILE}" ]; then
	rm "${DCOMP_BIN_FILE}"
fi

# CREATE THE LOCAL BIN DIRECTORY IF IT DOESN'T EXIST
if [ ! -d "${LOCAL_BIN_DIR}" ]; then
	echo "Creating '${LOCAL_BIN_DIR}' . . ."
	sudo mkdir -p "${LOCAL_BIN_DIR}"
fi

# CHANGE THE OWNER OF THE LOCAL BIN DIRECTORY IF NOT ALREADY
if { stat 2>&1 || true; } | grep -q 'stdin'; then
	OWNER_GROUP="$(stat -f %u:%g "${LOCAL_BIN_DIR}")"
else
	OWNER_GROUP="$(stat -c %u:%g "${LOCAL_BIN_DIR}")"
fi
if [ "${OWNER_GROUP}" != "$(id -u):$(id -g)" ]; then
	echo "Setting owner of '${LOCAL_BIN_DIR}' . . ."
	sudo chown $(id -u):$(id -g) "${LOCAL_BIN_DIR}"
fi

ln -s "${DCOMP_DIR}/dcomp.sh" "${DCOMP_BIN_FILE}"
export PATH="$(dirname "${DCOMP_BIN_FILE}"):${PATH}"

# CHECK IF THE INSTALLATION WAS SUCCESSFUL
if ! command -v dcomp >/dev/null 2>&1; then
	echo "dcomp failed to install."
	exit 1
fi

echo "dcomp installed successfully."
