{
  inputs,
  pkgs,
  wslHostname,
  username,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.default
    ../common/system.nix
    ../../modules/system/user.nix
    ../../modules/system/virtualization
  ];

  wsl.defaultUser = username;
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

  environment.systemPackages = with pkgs; [
    polkit_gnome
    adwaita-icon-theme
    gnome-themes-extra
    libnotify
    nautilus
  ];
}
