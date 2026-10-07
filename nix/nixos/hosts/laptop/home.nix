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

  development = {
    enable = true;
    git.enable = true;
    cloud.enable = true;
    containers.enable = true;
    kubernetes.enable = true;
    nix.enable = true;
    secrets.enable = true;
    tools.enable = true;
    desktop.enable = true;
    environment.enable = true;
    languages = {
      javascript = {
        enable = true;
        webstorm.enable = true;
      };
      c.enable = true;
      python.enable = true;
      dotnet = {
        enable = false;
        rider.enable = true;
      };
    };
    editors = {
      enable = true;
      zed.enable = true;
      vscode.enable = true;
      neovim.enable = true;
    };
  };
}
