## Info

This should work on **Windows** (wsl2), **macOS**, and **Linux** (any distro).

This automatically installs and configures the following:

- brew (*if macos*)
- bourne shell (*dash or busybox*)
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

## Setup (automatic)

```bash
curl -L https://raw.githubusercontent.com/JtMotoX/dotfiles/main/setup.sh | sh -s -- --checkout "main"
```

OR

```bash
wget -O - https://raw.githubusercontent.com/JtMotoX/dotfiles/main/setup.sh | sh -s -- --checkout "main"
```

## Setup (manual)

1. Install git

1. Run `git -C ~ clone https://github.com/JtMotoX/dotfiles.git`

1. Run `~/dotfiles/setup.sh`

## Development Testing

Spin up a container and execute `~/dotfiles/setup.sh`

Alpine:

```bash
docker run --rm -it -v "$(pwd):/dotfiles:ro" alpine sh -c "apk add --no-cache sudo && adduser -D myuser -u $(id -u) -g $(id -g) -s \$(command -v ash) && echo 'myuser ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/myuser && ln -s /dotfiles /home/myuser/dotfiles && su - myuser"
```

Ubuntu:

```bash
docker run --rm -it -v "$(pwd):/dotfiles:ro" ubuntu sh -c "apt-get update && apt-get install -y sudo && useradd -m myuser -u $(id -u) -g $(id -g) -s \$(command -v bash) && echo 'myuser ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/myuser && ln -s /dotfiles /home/myuser/dotfiles && su - myuser"
```

Arch:

```bash
docker run --rm -it -v "$(pwd):/dotfiles:ro" archlinux sh -c "pacman -Syu --noconfirm --needed sudo && if ! getent group $(id -g) >/dev/null 2>&1; then groupadd -g $(id -g) mygroup; fi && useradd -m -u $(id -u) -g $(id -g) -N -s \$(command -v bash) myuser && echo 'myuser ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/myuser && ln -s /dotfiles /home/myuser/dotfiles && su - myuser"
```

Alma:

```bash
docker run --rm -it -v "$(pwd):/dotfiles:ro" almalinux sh -c "yum install -y sudo && sed -i -E 's/^((UID|GID)_MIN\s*).*$/\11/' /etc/login.defs && if ! getent group $(id -g) >/dev/null 2>&1; then groupadd -g $(id -g) mygroup; fi && useradd -m -u $(id -u) -g $(id -g) -N -s \$(command -v bash) myuser && echo 'myuser ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/myuser && chmod 0440 /etc/sudoers.d/myuser && ln -s /dotfiles /home/myuser/dotfiles && su - myuser"
```
