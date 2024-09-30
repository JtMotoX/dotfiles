#!/bin/sh

set -e
cd "$(dirname "$0")"

# SET DEFAULT PYTHON VERSION
default_python_version=${1:-"3.10.3"}

# MAKE SURE PYENV IS INSTALLED
if ! command -v pyenv >/dev/null 2>&1; then
	echo "Pyenv is not installed"
	exit 1
fi

# # CHECK IF PYENV-VIRTUALENV IS INSTALLED
# if [ -d "$(pyenv root)/plugins/pyenv-virtualenv" ]; then
# 	echo "Updating pyenv-virtualenv"
# 	git -C $(pyenv root)/plugins/pyenv-virtualenv pull
# else
# 	# INSTALL PYENV-VIRTUALENV
# 	echo "Installing pyenv-virtualenv"
# 	git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
# fi

# CHECH IF PYTHON IS INSTALLED VIA PYENV
if pyenv versions --bare --skip-aliases --skip-envs | grep "${default_python_version}" >/dev/null 2>&1; then
	echo "Python ${default_python_version} is already installed via pyenv"
else
	# INSTALL PYTHON PREREQUISITES
	echo "Installing python prerequisites"
	if command -v apt-get >/dev/null 2>&1; then
		install_command="sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev"
	elif command -v pacman >/dev/null 2>&1; then
		install_command="sudo pacman -S --needed --noconfirm base-devel openssl zlib xz tk"
	elif command -v dnf >/dev/null 2>&1; then
		install_command="sudo dnf install -y make gcc patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel libuuid-devel gdbm-libs libnsl2"
	elif command -v brew >/dev/null 2>&1; then
		install_command="brew install openssl readline sqlite3 xz zlib tcl-tk"
	elif command -v port >/dev/null 2>&1; then
		install_command="sudo port install pkgconfig openssl zlib xz gdbm tcl tk +quartz sqlite3 sqlite3-tcl"
	elif command -v zypper >/dev/null 2>&1; then
		install_command="sudo zypper install -y gcc automake bzip2 libbz2-devel xz xz-devel openssl-devel ncurses-devel readline-devel zlib-devel tk-devel libffi-devel sqlite3-devel gdbm-devel make findutils patch"
	elif command -v yum >/dev/null 2>&1; then
		install_command="sudo yum install -y gcc make patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel"
	elif command -v apk >/dev/null 2>&1; then
		install_command="sudo apk add --no-cache git bash build-base libffi-dev openssl-dev bzip2-dev zlib-dev xz-dev readline-dev sqlite-dev tk-dev"
	else
		echo "ERROR: Unsupported package manager. Please install python dependencies with your package manager"
		echo "WARN: Going to attempt to install python without these tools"
	fi
	if [ "${install_command}" != "" ]; then
		echo "Executing: ${install_command}"
		sh -c "${install_command}"
	fi

	# INSTALL PYTHON VIA PYENV
	echo "Installing python via pyenv"
	pyenv install ${default_python_version}
fi

# SET GLOBAL PYTHON VERSION
pyenv global ${default_python_version}
