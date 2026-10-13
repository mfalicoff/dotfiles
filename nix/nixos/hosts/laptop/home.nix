{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ../../modules/home
  ];

  home.username = "mazilious";
  home.homeDirectory = "/home/mazilious";
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.nh = {
    enable = true;
  };

  home.packages = with pkgs; [
    insync
    insync-nautilus
    _1password-gui
    _1password-cli
    discord
  ];

  # Settings for this machine
  windowManager = {
    enable = true;
    wayland = {
      enable = true;
      hyprland.enable = true;
      bar.waybar.enable = true;
    };
  };

  profiles.devWorkstation.enable = true;

  development = {
    desktop.enable = true;
    languages = {
      javascript = {
        enable = true;
        webstorm.enable = true;
      };
      dotnet = {
        enable = false;
        rider.enable = true;
      };
    };
    editors = {
      zed.enable = true;
      vscode.enable = true;
    };
  };
}
