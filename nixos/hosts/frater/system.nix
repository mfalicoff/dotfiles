{
  inputs,
  config,
  pkgs,
  wslHostname,
  ...
}: {
  imports = [
     inputs.home-manager.nixosModules.default
    ../common/system.nix
    # ../../modules/system/boot
    # ../../modules/system/gaming
    # ../../modules/system/greetd
    # ../../modules/system/hyprland
    # ../../modules/system/nvidia
     ../../modules/system/user.nix
     ../../modules/system/virtualization
  ];

  #wsl
  environment.systemPackages = [
          pkgs.vscode];

  wsl.defaultUser = "mazilious";
  wsl.enable = true;

  # Networking
  networking.networkmanager.enable = true;
  networking.hostName = wslHostname;

  programs.ssh.startAgent = true;
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
    };
  };

  #Locales
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  programs.nix-ld.enable = true;

  system.stateVersion = "24.11";

  # # Custom Modules
  # styling.stylix = {
  #   enable = true;
  # };

  # stylix.cursor.package = pkgs.bibata-cursors;
  # stylix.cursor.name = "Bibata-Modern-Ice";
  # stylix.cursor.size = 20;
  # fonts.enableDefaultPackages = true;

  # loginManager.enable = true;
  # wm.hyprland.enable = true;

  # gaming = {
  #   enable = true;
  # };

  # hardware.graphics.nvidia = {
  #   enable = true;
  #   driverPackage = config.boot.kernelPackages.nvidiaPackages.beta;
  #   useOpenSource = false;
  #   enableModesetting = true;
  #   enableSettings = true;
  # };

  # environment.systemPackages = with pkgs; [
  #   polkit_gnome
  #   adwaita-icon-theme
  #   gnome-themes-extra
  #   libnotify
  #   alacritty
  #   nautilus
  #   bluetuith
  # ];
}
