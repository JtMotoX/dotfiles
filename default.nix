{ pkgs ? import <nixpkgs> {} }:

let
  # https://lazamar.co.uk/nix-versions

  # stable-22.05
  # pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/040c6d8374d090f46ab0e99f1f7c27a4529ecffd.tar.gz") {};

  # jq 1.6
  jq_pin = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/976fa3369d722e76f37c77493d99829540d43845.tar.gz") {};

  # velero 1.9.3
  velero_pin = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/b3a285628a6928f62cdf4d09f4e656f7ecbbcafb.tar.gz") {};
in
# https://search.nixos.org/packages
pkgs.mkShell {
  packages = with pkgs; [ 
    git
    kind
    kubectl
    yq-go
    jq_pin.jq
    pyenv
    velero_pin.velero
    docker
    zoxide
    fzf
    fzf-zsh
    tmux
    oh-my-zsh
  ];
  shellHook = ''
    [ "$SHELL_REAL" != "" ] && export SHELL=$SHELL_REAL # PREVENT TMUX FROM LOADING NIX-SHELL BASH
  '';
}