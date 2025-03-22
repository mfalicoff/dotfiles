{darwinHostname, ...}: {
  imports = [
    ../../modules/system/homebrew
    ../../modules/system/nix-darwin
    ../../modules/system/stylix
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

  # Custom Modules
  styling.stylix = {
    enable = true;
  };

  homebred = {
    enable = true;
    taps = [
      "homebrew/services"
      "FelixKratz/formulae"
    ];
    brews = [
      "mas"
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
