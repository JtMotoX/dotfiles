#!/bin/sh

set -e
cd "$(dirname "$0")"

# sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
# sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

nix-env -f ../configs/packages.nix -iA environment.systemPackages
