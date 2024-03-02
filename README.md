## Info

This should work on **Windows** (wsl2), **macOS**, and **Linux** (any distro).

This automatically installs and configures the following:

- brew (*if macos*)
- bourne shell (*dash*)
- pyenv
- python
- zsh
- oh-my-zsh
- ansible
- vim
- nix
- *all the packages listed in [packages.nix](configs/packages.nix)*
- *all the aliases and functions listed in [sh_profile_custom](configs/sh_profile_custom)*

---

## Setup

1. Install git

1. Run `git -C ~ clone https://github.com/JtMotoX/dotfiles.git`

1. Run `~/dotfiles/setup.sh`
