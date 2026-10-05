{
  config,
  lib,
  username,
  ...
}:
{
  options.macos.desktop.enable = lib.mkEnableOption "macOS desktop configuration";
  config = lib.mkIf (config.macos.enable && config.macos.desktop.enable) {
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
  };
}
