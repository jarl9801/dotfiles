#!/bin/bash
# setup.sh — Run this on the Mac Mini (source machine) to collect dotfiles
# Usage: bash ~/Dev/dotfiles/setup.sh

set -e

DOTFILES_DIR="$HOME/Dev/dotfiles"
HOSTNAME=$(hostname -s)

echo "🔧 Collecting dotfiles from $HOSTNAME..."
echo ""

# 1. Generate Brewfile
echo "🍺 Generating Brewfile..."
brew bundle dump --file="$DOTFILES_DIR/Brewfile" --force
echo "   ✅ Brewfile created ($(wc -l < "$DOTFILES_DIR/Brewfile") entries)"

# 2. Copy dotfiles
echo ""
echo "📄 Copying dotfiles..."

copy_if_exists() {
    local src="$1"
    local dest="$DOTFILES_DIR/$2"
    if [ -f "$src" ]; then
        cp "$src" "$dest"
        echo "   ✅ $2"
    else
        echo "   ⏭️  $src not found, skipping"
    fi
}

copy_if_exists "$HOME/.zshrc" "zshrc"
copy_if_exists "$HOME/.zprofile" "zprofile"
copy_if_exists "$HOME/.gitconfig" "gitconfig"
copy_if_exists "$HOME/.gitignore_global" "gitignore_global"
copy_if_exists "$HOME/.npmrc" "npmrc"
copy_if_exists "$HOME/.vimrc" "vimrc"
copy_if_exists "$HOME/.warprc" "warprc"
copy_if_exists "$HOME/.ssh/config" "ssh_config"

# 3. Copy Warp config if present
if [ -d "$HOME/.warp" ]; then
    echo ""
    echo "⚡ Copying Warp config..."
    mkdir -p "$DOTFILES_DIR/warp"
    cp -R "$HOME/.warp/themes" "$DOTFILES_DIR/warp/" 2>/dev/null && echo "   ✅ warp/themes" || echo "   ⏭️  No Warp themes"
    cp -R "$HOME/.warp/workflows" "$DOTFILES_DIR/warp/" 2>/dev/null && echo "   ✅ warp/workflows" || echo "   ⏭️  No Warp workflows"
fi

# 4. VS Code extensions list
if command -v code &> /dev/null; then
    echo ""
    echo "📦 Listing VS Code extensions..."
    code --list-extensions > "$DOTFILES_DIR/vscode-extensions.txt"
    echo "   ✅ vscode-extensions.txt ($(wc -l < "$DOTFILES_DIR/vscode-extensions.txt") extensions)"
fi

# 5. macOS defaults (useful ones)
echo ""
echo "🍎 Saving macOS preferences..."
cat > "$DOTFILES_DIR/macos-defaults.sh" << 'MACOS_EOF'
#!/bin/bash
# macOS defaults — run this to apply preferred settings

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 48

# Finder
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Keyboard
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Screenshots
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"

echo "✅ macOS defaults applied. Some changes require logout."
MACOS_EOF
chmod +x "$DOTFILES_DIR/macos-defaults.sh"
echo "   ✅ macos-defaults.sh"

# 6. Init git repo
echo ""
echo "📦 Initializing git repo..."
cd "$DOTFILES_DIR"
if [ ! -d .git ]; then
    git init
    echo "   ✅ Git initialized"
else
    echo "   ⏭️  Already a git repo"
fi

# Create .gitignore for sensitive files
cat > "$DOTFILES_DIR/.gitignore" << 'GIT_EOF'
# Never commit secrets
*.key
*.pem
*credentials*
*secret*
*token*
.env
.env.*
GIT_EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Done! Your dotfiles are in: $DOTFILES_DIR"
echo ""
echo "Next steps:"
echo "  1. Review the files: ls -la $DOTFILES_DIR"
echo "  2. Commit: cd $DOTFILES_DIR && git add -A && git commit -m 'Initial dotfiles from $HOSTNAME'"
echo "  3. Push: gh repo create dotfiles --public --source=. --push"
echo "  4. On MacBook Air: bash ~/Dev/dotfiles/install.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
