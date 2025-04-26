{darwinHostname, ...}: {
  imports = [
    ../common/system.nix
    ../../modules/system/homebrew
    ../../modules/system/nix-darwin
  ];

  # Networking
  networking.hostName = darwinHostname;
  networking.computerName = darwinHostname;
  system.defaults.smb.NetBIOSName = darwinHostname;
  # services.openssh = {
  #   enable = true;
  #   ports = [22];
  #   settings = {
  #     PasswordAuthentication = false;
  #   };
  # };

  #Locales
  time.timeZone = "America/Toronto";

  homebred = {
    enable = true;
    taps = [
      "homebrew/services"
      "FelixKratz/formulae"
    ];
    brews = [
      "mas"
      "sketchybar"
    ];
    casks = [
      "rider"
      "webstorm"
      "insync"
      "stats"
      "orbstack"
    ];
    appStoreApps = {
      Tailscale = 1475387142;
      Infuse = 1136220934;
      AutoMounter = 1160435653;
    };
  };
}
