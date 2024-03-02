#!/bin/sh

set -e
cd "$(dirname "$0")"

mkdir -p ~/.tmux/plugins/

# # INSTALL TMUX PLUGIN MANAGER (currently disabled since causes sustained cpu spike on wsl2)
# git -C ~/.tmux/plugins clone https://github.com/tmux-plugins/tpm
# $TMUX_PLUGIN_MANAGER_PATH/tpm/scripts/install_plugins.sh
