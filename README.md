## Setup

1. Follow the setup steps at the top of the [tmux.conf](configs/tmux.conf)
1. Run `./setup.sh`

---

## Troubleshooting

If you get a `compaudit` error, run the following command:
```bash
compaudit | xargs chmod g-w
```

---

## Install Bourne Shell (optional)

Run the command below to see if you have a bourne shell:

```bash
ls -l "$(which sh)"|sed 's/[^\/]*//';sh -c 'a="a";echo ${a[@]}'>/dev/null 2>&1&&echo "Not bourne shell"||echo "Bourne shell"
```

If you do not have a bourne shell, then you can install something like Dash. Example with AlmaLinux below. RECOMMEND MOVING `/bin/sh` to `/bin/sh.original` IF IT IS A FILE. ONLY `rm` IT IF IT IS A SYMLINK.

```bash
sudo dnf install -y dash
sudo rm -f /usr/bin/sh
sudo ln -s dash /usr/bin/sh
```
