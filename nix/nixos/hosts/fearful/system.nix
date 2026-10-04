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

  # Nix manages available packages; Homebrew covers vendor apps and packages
  # without a suitable Darwin build. Removed declarations are uninstalled on
  # activation.
  homebred = {
    enable = true;
    taps = [ "kartax/tap" "skyhook-io/tap" ];
    brews = [
      "proton-pass-cli"
    ];
    casks = [
      "bruno"
      "chatgpt"
      "claude-code"
      "discord"
      "dotnet-sdk"
      "firefox"
      "github"
      "gitkraken"
      "google-chrome"
      "homebrew-app"
      "kartax/tap/immich-desktop"
      "insync"
      "jetbrains-toolbox"
      "mongodb-compass"
      "orbstack"
      "proton-mail"
      "skyhook-io/tap/radar-desktop"
      "raycast"
      "spotify"
      "wallspace"
      "whatsapp"
      "yubico-authenticator"
      "zed"
      "zen"
    ];
    appStoreApps = {
      Amphetamine = 937984704;
      AutoMounter = 1160435653;
      Tailscale = 1475387142;
      "Infuse 7" = 1136220934;
    };
  };
}
