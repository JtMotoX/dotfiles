#!/bin/sh

# LOAD BREW ENVIRONMENT
if [ "${BREW_SHELL_ENV}" = "" ]; then BREW_SHELL_ENV="$(/opt/homebrew/bin/brew shellenv 2>/dev/null || true)"; fi
if [ "${BREW_SHELL_ENV}" = "" ]; then BREW_SHELL_ENV="$(/home/linuxbrew/.linuxbrew/bin/brew shellenv 2>/dev/null || true)"; fi
if [ "${BREW_SHELL_ENV}" != "" ]; then eval "${BREW_SHELL_ENV}"; fi
unset BREW_SHELL_ENV
