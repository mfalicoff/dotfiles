{config, darwinHostname, username, ...}: {
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

  # The Nix store path of Zen changes on every upgrade. Gecko treats each
  # path as a new installation unless legacy profile selection is enabled.
  launchd.user.envVariables.MOZ_LEGACY_PROFILES = "1";
  launchd.user.agents.zenLegacyProfiles.serviceConfig = {
    ProgramArguments = ["/bin/launchctl" "setenv" "MOZ_LEGACY_PROFILES" "1"];
    RunAtLoad = true;
  };
  assertions = [
    {
      assertion = config.home-manager.users.${username}.programs.zen-browser.enable;
      message = "The fearful host must keep Zen enabled to preserve its managed profile and extensions.";
    }
  ];

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
      "kartax/tap/immich-desktop"
      "insync"
      "proton-mail"
      "skyhook-io/tap/radar-desktop"
      "wallspace"
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
