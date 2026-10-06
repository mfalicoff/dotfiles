{darwinHostname, ...}: {
  imports = [
    ./host-users.nix
    ../../modules/system/stylix
    ../../modules/system/homebrew
    ../../modules/system/nix-darwin
  ];

  styling.stylix.enable = true;

  macos = {
    enable = true;
    keyboard.enable = true;
    login.enable = true;
    desktop.enable = true;
    security.enable = true;
  };

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
    taps = [
      "frostymur/tap"
      "kartax/tap"
      "skyhook-io/tap"
    ];
    brews = [
      "proton-pass-cli"
      "mole"
    ];
    casks = [
      "chatgpt"
      "kartax/tap/immich-desktop"
      "insync"
      "mongodb-compass"
      "orbstack"
      "proton-mail"
      "skyhook-io/tap/radar-desktop"
      "spotify"
      "wallspace"
      "whatsapp"
      "yubico-authenticator"
      "vorssaint"
    ];
    appStoreApps = {
      AutoMounter = 1160435653;
      "Infuse 7" = 1136220934;
    };
  };

  # Aerofi needs a running user service to handle its global launcher hotkey.
  homebrew.brews = [
    {
      name = "frostymur/tap/aerofi";
      start_service = true;
      restart_service = "changed";
    }
  ];
}
