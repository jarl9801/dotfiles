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
