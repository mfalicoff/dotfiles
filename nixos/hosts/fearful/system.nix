{darwinHostname, ...}: {
  imports = [
    ../../modules/system/stylix
    ../../modules/system/homebrew
    ../../modules/system/nix-darwin
  ];

  styling.stylix = {
    enable = true;
  };

  # Networking
  networking.hostName = darwinHostname;
  networking.computerName = darwinHostname;
  system.defaults.smb.NetBIOSName = darwinHostname;

  #Locales
  time.timeZone = "America/Toronto";

  homebred = {
    enable = true;
    taps = [
      "homebrew/services"
    ];
    brews = [
      "mas"
      "node"
      "go"
    ];
    casks = [
      # Security & Authentication
      "1password"
      "1password-cli"
      "yubico-authenticator"

      # Browsers
      "firefox"
      "google-chrome"
      "zen"

      # Productivity & Notes
      "affine"
      "raycast"

      # Media & Entertainment
      "calibre"
      "discord"
      "spotify"

      # Cloud Storage & Sync
      "insync"
      "opencloud"
      "proton-mail"

      # System Utilities
      "only-switch"
      "stats"
      "android-file-transfer"

      # Virtualization
      "vmware-fusion"

      # Fitness & Health
      "garmin-express"

      # Development Tools
      "dotnet-sdk"
      "ghostty"
      "gitkraken"
      "jetbrains-toolbox"
      "orbstack"
      "yaak"
      "zed"
      "mongodb-compass"
    ];
    appStoreApps = {
      # Productivity
      Amphetamine = 937984704;
      AutoMounter = 1160435653;

      # Networking
      Tailscale = 1475387142;

      # Media
      Infuse = 1136220934;

      # Remote Desktop
      WindowsApp = 1295203466;
    };
  };
}
