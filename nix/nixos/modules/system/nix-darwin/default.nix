{ pkgs, username, ... }:
{
  # nix-darwin copies .app bundles from system packages into
  # /Applications/Nix Apps, where macOS can index them.
  environment.systemPackages = with pkgs; [
    vscode
  ];

  # Keep the version from the previous nix-darwin installation.
  system.stateVersion = 5;
  system.primaryUser = username;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  programs.nix-plist-manager = {
    enable = true;
    options.applications.systemSettings.lockScreen.loginWindowShows = "Name and password";
  };

  # Settings without equivalent nix-plist-manager options stay with nix-darwin.
  system.defaults = {
    finder = {
      _FXShowPosixPathInTitle = true;
      QuitMenuItem = true;
    };
    # The plist manager's dragging option changes other drag gestures too.
    trackpad.TrackpadThreeFingerDrag = false;
    NSGlobalDomain = {
      # The plist manager's keyboard navigation toggle writes 2, not 3.
      AppleKeyboardUIMode = 3;
      ApplePressAndHoldEnabled = true;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
    };
    loginwindow.GuestEnabled = false;
    CustomUserPreferences = {
      NSGlobalDomain.WebKitDeveloperExtras = true;
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.screensaver" = {
        askForPassword = 1;
        askForPasswordDelay = 0;
      };
      "com.apple.screencapture" = {
        location = "/Users/${username}/Desktop";
        type = "png";
      };
      "com.apple.ImageCapture".disableHotPlug = true;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
