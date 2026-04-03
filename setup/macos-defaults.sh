#!/usr/bin/env bash
# macos-defaults.sh — fearful
# Applies macOS system preferences, translated from nix-darwin system.nix
# Run once after a fresh install. Log out and back in after running.
# Usage: bash macos-defaults.sh

set -euo pipefail

echo "Applying macOS defaults..."

# ─────────────────────────────────────────────
# HOSTNAME
# ─────────────────────────────────────────────
sudo scutil --set ComputerName "fearful"
sudo scutil --set LocalHostName "fearful"
sudo scutil --set HostName "fearful"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "fearful"

# ─────────────────────────────────────────────
# DOCK
# ─────────────────────────────────────────────
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false

# ─────────────────────────────────────────────
# FINDER
# ─────────────────────────────────────────────
# Show full POSIX path in title bar
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# No warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Show path bar
defaults write com.apple.finder ShowPathbar -bool true
# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true
# Folders sorted first
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Search in current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# Show external drives on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
# Enable Quit Finder menu item
defaults write com.apple.finder QuitMenuItem -bool true

# ─────────────────────────────────────────────
# TRACKPAD
# ─────────────────────────────────────────────
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool false

# ─────────────────────────────────────────────
# KEYBOARD
# ─────────────────────────────────────────────
# CapsLock → Escape (requires hidutil, set via keyboard shortcut system)
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}' > /dev/null

# Make it persist on reboot via a LaunchAgent
mkdir -p ~/Library/LaunchAgents
cat > ~/Library/LaunchAgents/com.local.KeyRemapping.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.local.KeyRemapping</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/hidutil</string>
        <string>property</string>
        <string>--set</string>
        <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
launchctl load ~/Library/LaunchAgents/com.local.KeyRemapping.plist 2>/dev/null || true

# Key repeat (fast)
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain KeyRepeat -int 3

# Full keyboard control (tab through all controls)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Press and hold enabled (good for holding keys like hjkl in vim)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool true

# ─────────────────────────────────────────────
# APPEARANCE & LANGUAGE
# ─────────────────────────────────────────────
# Dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Natural scrolling
defaults write NSGlobalDomain "com.apple.swipescrolldirection" -bool true

# Disable beep on volume change
defaults write NSGlobalDomain "com.apple.sound.beep.feedback" -int 0

# Autocorrect / substitutions — all off
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Expanded save panels by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Web inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# ─────────────────────────────────────────────
# SECURITY
# ─────────────────────────────────────────────
# Screen saver password immediately
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Disable guest user
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

# Disable personalized Apple Ads
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false

# Stop Photos from opening automatically
defaults write com.apple.ImageCapture disableHotPlug -bool true

# ─────────────────────────────────────────────
# SPACES & WINDOW MANAGER
# ─────────────────────────────────────────────
# Switch to app's space on activation
defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -bool true

# Separate spaces per display
defaults write com.apple.spaces "spans-displays" -int 0

# Stage Manager / Window Manager
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -int 0
defaults write com.apple.WindowManager StandardHideDesktopIcons -int 1
defaults write com.apple.WindowManager HideDesktop -int 1
defaults write com.apple.WindowManager StageManagerHideWidgets -int 0
defaults write com.apple.WindowManager StandardHideWidgets -int 0

# ─────────────────────────────────────────────
# MISC
# ─────────────────────────────────────────────
# No .DS_Store on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Screenshots: Desktop, PNG format
defaults write com.apple.screencapture location -string "${HOME}/Desktop"
defaults write com.apple.screencapture type -string "png"

# Show ~/Library
chflags nohidden ~/Library

# ─────────────────────────────────────────────
# APPLY SETTINGS
# ─────────────────────────────────────────────
echo "Restarting affected apps..."
for app in "Finder" "Dock" "SystemUIServer"; do
  killall "${app}" &>/dev/null || true
done

echo ""
echo "Done! Log out and back in for all settings to take effect."
echo ""
echo "Note: TouchID for sudo requires manual setup:"
echo "  sudo nano /etc/pam.d/sudo_local"
echo "  Add: auth sufficient pam_tid.so"
