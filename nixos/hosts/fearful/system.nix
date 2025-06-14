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
      "1password"
      "1password-cli"
      "calibre"
      "firefox"
      "google-chrome"
      "only-switch"
      "proton-mail"
      "stats"
      "vmware-fusion"

      # dev
      "dotnet-sdk"
      "gitkraken"
      "jetbrains-toolbox"
      "orbstack"
      "yaak"
    ];
    appStoreApps = {
      Amphetamine = 937984704;
      Tailscale = 1475387142;
      Infuse = 1136220934;
      AutoMounter = 1160435653;
      WindowsApp = 1295203466;
    };
  };
}
