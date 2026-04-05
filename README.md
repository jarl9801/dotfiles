# Dotfiles — Jarl's Mac Sync

Synchronized configuration between Mac Mini M4 and MacBook Air M4.

## Quick Start

### On Mac Mini (source):
```bash
bash ~/Dev/dotfiles/setup.sh
cd ~/Dev/dotfiles
git add -A && git commit -m "Initial dotfiles"
gh repo create dotfiles --public --source=. --push
```

### On MacBook Air (target):
```bash
git clone https://github.com/jarl9801/dotfiles.git ~/Dev/dotfiles
bash ~/Dev/dotfiles/install.sh
```

## What's Included
- Brewfile (all Homebrew packages, casks, taps)
- Shell config (.zshrc, .zprofile)
- Git config (.gitconfig, .gitignore_global)
- SSH config
- Warp themes and workflows
- VS Code extensions list
- macOS defaults

## Updating
After changing config on either Mac:
```bash
cd ~/Dev/dotfiles
bash setup.sh          # re-collect
git add -A && git commit -m "Update dotfiles"
git push
```

On the other Mac:
```bash
cd ~/Dev/dotfiles
git pull
bash install.sh
```
