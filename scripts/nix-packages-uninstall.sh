#!/bin/sh

set -e
cd "$(dirname "$0")"

echo "Removing existing nix packages to avoid conflict . . ."
nix-env -e '*'
