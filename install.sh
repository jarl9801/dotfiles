#!/bin/bash
# install.sh — Run this on the MacBook Air (target machine) to apply dotfiles
# Usage:
#   git clone https://github.com/jarl9801/dotfiles.git ~/Dev/dotfiles
#   bash ~/Dev/dotfiles/install.sh

set -e

DOTFILES_DIR="$HOME/Dev/dotfiles"
HOSTNAME=$(hostname -s)
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d)"

echo "📥 Installing dotfiles on $HOSTNAME..."
echo "   Backups will be saved to: $BACKUP_DIR"
echo ""

mkdir -p "$BACKUP_DIR"

# Helper: backup existing file, then symlink
link_dotfile() {
    local src="$DOTFILES_DIR/$1"
    local dest="$HOME/$2"

    if [ ! -f "$src" ]; then
        echo "   ⏭️  $1 not in repo, skipping"
        return
    fi

    # Backup existing
    if [ -f "$dest" ] && [ ! -L "$dest" ]; then
        cp "$dest" "$BACKUP_DIR/$(basename $dest)"
        echo "   💾 Backed up existing $2"
    fi

    # Remove old symlink or file
    rm -f "$dest"

    # Create symlink
    ln -s "$src" "$dest"
    echo "   ✅ $2 → $src"
}

# 1. Install Homebrew if missing
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "   ✅ Homebrew installed"
else
    echo "🍺 Homebrew already installed"
fi

# 2. Install packages from Brewfile
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    echo ""
    echo "📦 Installing packages from Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
    echo "   ✅ Brewfile applied"
fi

# 3. Symlink dotfiles
echo ""
echo "🔗 Symlinking dotfiles..."

link_dotfile "zshrc" ".zshrc"
link_dotfile "zprofile" ".zprofile"
link_dotfile "gitconfig" ".gitconfig"
link_dotfile "gitignore_global" ".gitignore_global"
link_dotfile "npmrc" ".npmrc"
link_dotfile "vimrc" ".vimrc"
link_dotfile "warprc" ".warprc"

# SSH config (special handling — don't overwrite keys)
if [ -f "$DOTFILES_DIR/ssh_config" ]; then
    mkdir -p "$HOME/.ssh"
    if [ -f "$HOME/.ssh/config" ]; then
        cp "$HOME/.ssh/config" "$BACKUP_DIR/ssh_config"
        echo "   💾 Backed up existing .ssh/config"
    fi
    ln -sf "$DOTFILES_DIR/ssh_config" "$HOME/.ssh/config"
    echo "   ✅ .ssh/config → $DOTFILES_DIR/ssh_config"
fi

# 4. Warp config
if [ -d "$DOTFILES_DIR/warp" ]; then
    echo ""
    echo "⚡ Applying Warp config..."
    mkdir -p "$HOME/.warp"
    [ -d "$DOTFILES_DIR/warp/themes" ] && cp -R "$DOTFILES_DIR/warp/themes" "$HOME/.warp/" && echo "   ✅ Warp themes"
    [ -d "$DOTFILES_DIR/warp/workflows" ] && cp -R "$DOTFILES_DIR/warp/workflows" "$HOME/.warp/" && echo "   ✅ Warp workflows"
fi

# 5. VS Code extensions
if [ -f "$DOTFILES_DIR/vscode-extensions.txt" ] && command -v code &> /dev/null; then
    echo ""
    echo "📦 Installing VS Code extensions..."
    while IFS= read -r ext; do
        code --install-extension "$ext" --force 2>/dev/null && echo "   ✅ $ext" || echo "   ⚠️  Failed: $ext"
    done < "$DOTFILES_DIR/vscode-extensions.txt"
fi

# 6. macOS defaults
if [ -f "$DOTFILES_DIR/macos-defaults.sh" ]; then
    echo ""
    read -p "🍎 Apply macOS defaults? (y/n) " apply_defaults
    if [ "$apply_defaults" = "y" ]; then
        bash "$DOTFILES_DIR/macos-defaults.sh"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Done! Dotfiles installed on $HOSTNAME"
echo "   Backups saved to: $BACKUP_DIR"
echo ""
echo "⚠️  Restart your terminal to apply .zshrc changes"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
