#!/bin/sh

set -e
cd "$(dirname "$0")"

# sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
# sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

echo "Installing nix packages . . ."
nix-env -f "../configs/packages.nix" -iA environment.systemPackages
echo "Nix packages installed."

# if [ "$(uname)" = "Linux" ]; then
# 	echo "Installing linux packages . . ."
# 	nix-env -f "../configs/packages-linux.nix" -iA environment.systemPackages
# 	echo "Linux packages installed."
# fi
