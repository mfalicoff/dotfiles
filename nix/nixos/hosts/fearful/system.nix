{ darwinHostname, ... }:
{
  imports = [
    ./host-users.nix
    ../../modules/system/stylix
    ../../modules/system/homebrew
    ../../modules/system/nix-darwin
  ];

  styling.stylix.enable = true;

  networking.hostName = darwinHostname;
  networking.computerName = darwinHostname;
  system.defaults.smb.NetBIOSName = darwinHostname;
  time.timeZone = "America/Toronto";

  services.tailscale.enable = true;

  # Nix manages available packages; Homebrew covers vendor apps and packages
  # without a suitable Darwin build. Removed declarations are uninstalled on
  # activation.
  homebred = {
    enable = true;
    taps = [ "kartax/tap" "skyhook-io/tap" ];
    brews = [
      "proton-pass-cli"
      "mole"
    ];
    casks = [
      "chatgpt"
      # "discord"
      "dotnet-sdk"
      "firefox"
      "google-chrome"
      "kartax/tap/immich-desktop"
      "insync"
      "mongodb-compass"
      "orbstack"
      "proton-mail"
      "skyhook-io/tap/radar-desktop"
      "raycast"
      "spotify"
      "wallspace"
      "whatsapp"
      "yubico-authenticator"
      "vorssaint"
      "zed"
    ];
    appStoreApps = {
      AutoMounter = 1160435653;
      "Infuse 7" = 1136220934;
    };
  };
}
