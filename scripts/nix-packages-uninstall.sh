#!/bin/sh

set -e
cd "$(dirname "$0")"

nix-env -e '*'
