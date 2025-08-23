{
  inputs,
  config,
  pkgs,
  desktopHostname,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.default
    ../../modules/system/user.nix
    ../../modules/system
    ./hardware-configuration.nix
  ];

  # Networking
  networking.networkmanager.enable = true;
  networking.hostName = desktopHostname;

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

  # Custom Modules
  bootManager.enable = true;
  gaming.enable = true;
  loginManager.enable = true;
  passwordManager.enable = true;
  smb.enable = true;
  sshServer.enable = true;
  styling.stylix.enable = true;
  virt.enable = true;
  wm.hyprland.enable = true;
  calibre.enable = true;

  hardware.graphics.nvidia = {
    enable = true;
    driverPackage = config.boot.kernelPackages.nvidiaPackages.beta;
    useOpenSource = false;
    enableModesetting = true;
    enableSettings = true;
  };

  environment.systemPackages = with pkgs; [
    polkit_gnome
    adwaita-icon-theme
    gnome-themes-extra
    libnotify
    nautilus
    bluetuith

    ## custom script
    (writeScriptBin "set-1080" ''
      #!${bash}/bin/bash
      ${hyprland}/bin/hyprctl keyword monitor "DP-1,1920x1080@164.90,0x0,1,bitdepth,10"
      echo "Display changed to centered 2560x1440 @ 60Hz"
    '')

    (writeScriptBin "set-1440" ''
      #!${bash}/bin/bash
      ${hyprland}/bin/hyprctl keyword monitor "DP-1,2560x1440@59.95,0x0,1,bitdepth,10"
      echo "Display changed to centered 2560x1440 @ 60Hz"
    '')

    (writeScriptBin "set-normal" ''
      #!${bash}/bin/bash
      ${hyprland}/bin/hyprctl keyword monitor "DP-1,3440x1440@164.90,0x0,1,bitdepth,10"
      echo "Display restored to 3440x1440 @ 164.90Hz"
    '')
  ];
}
