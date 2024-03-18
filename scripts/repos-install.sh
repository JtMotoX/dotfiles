#!/bin/sh

# INSTALL EPEL REPO
if command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
	sudo dnf install -y epel-release
fi
