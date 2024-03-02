#!/bin/sh

set -e
cd "$(dirname "$0")"

# SET DEFAULT PYTHON VERSION
default_python_version=${1:-"3.10.3"}

# CHECK IF PYENV IS INSTALLED
if command -v pyenv >/dev/null 2>&1; then
	echo "pyenv is already installed"
else
	# INSTALL PYENV
	echo "Installing pyenv"
	curl https://pyenv.run | sh
fi

# CHECK IF PYENV-VIRTUALENV IS INSTALLED
if [ -d "$(pyenv root)/plugins/pyenv-virtualenv" ]; then
	echo "Updating pyenv-virtualenv"
	git -C $(pyenv root)/plugins/pyenv-virtualenv pull
else
	# INSTALL PYENV-VIRTUALENV
	echo "Installing pyenv-virtualenv"
	git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
fi

# CHECH IF PYTHON IS INSTALLED VIA PYENV
if pyenv versions --bare --skip-aliases --skip-envs | grep "${default_python_version}" >/dev/null 2>&1; then
	echo "Python ${default_python_version} is already installed via pyenv"
else
	# INSTALL PYTHON VIA PYENV
	echo "Installing python via pyenv"
	pyenv install ${default_python_version}
fi

# SET GLOBAL PYTHON VERSION
pyenv global ${default_python_version}
