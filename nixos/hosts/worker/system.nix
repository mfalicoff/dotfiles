{
  inputs,
  workerHostname,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.default
    ./hardware-configuration.nix
    ../../modules/system
  ];

  # Networking
  networking.networkmanager.enable = true;
  networking.hostName = workerHostname;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.tailscale.enable = true;

  #Locales
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  #Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  programs.nix-ld.enable = true;

  system.stateVersion = "24.11";

  # Custom
  styling.stylix.enable = true;
  smb.enable = true;
  bootManager.enable = true;
  reverseProxy.enable = true;
  sshServer.enable = true;

  homelab = {
    enable = true;
    services.enable = true;
    monitoring.enable = true;
  };
}
