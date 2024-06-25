# LIST INSTALLED PACKAGES
# nix-env -q

# INSTALL PACKAGES.NIX
# nix-env -f packages.nix -iA environment.systemPackages

# REMOVE ALL PACKAGES
# nix-env -e '*'

######################################

{ pkgs ? import <nixpkgs> {} }:

let
  # inludes velero 1.9.3
  velero_pin = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/b3a285628a6928f62cdf4d09f4e656f7ecbbcafb.tar.gz") {};
  # inludes kubectl 1.25.4
  kubectl_pin = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/b3a285628a6928f62cdf4d09f4e656f7ecbbcafb.tar.gz") {};
  # unstable
  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {};
in

{
  environment.systemPackages = with pkgs; [
    git
    git-crypt
    kind
    kubectl_pin.kubectl
    # kubectx
    unstable.kubeswitch
    kubernetes-helm
    yq-go
    jq
    velero_pin.velero
    docker-compose
    zoxide
    fzf
    fzf-zsh
    # devbox
    # direnv
    tmux
    util-linux # chsh
    ncurses # clear
    inetutils # hostname, ping, ifconfig, telnet, etc..
    ncdu
    bash
    which
    dash
    gh
    # PYTHON & DEPENDENCIES
    python3Full
    python3Packages.pip
    python3Packages.virtualenv
    # python3Packages.tkinter
    pyenv
    # gcc
    # gnumake
    # zlib
    # zlib.dev
    # zlib.out
    # pkgconfig haskell.compiler.ghc8107
    # ccls
    pkg-config
    # python3Packages.pyramid
    # openssl
    # xz

    # gdbm
    # lzma
    # tk
    # readline
    # setuptools
    ###
  ];
}
