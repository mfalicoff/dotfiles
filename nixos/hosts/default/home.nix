{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
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
    firefox
    google-chrome
    _1password-gui
    _1password-cli
    vlc
    discord
  ];

  # Settings for this machine
  windowManager = {
    wayland = {
      enable = true;

      hyprland = {
        enable = true;
        monitors = [
          "DP-1, 3440x1440@164.90, 0x0, 1, bitdepth, 10"
        ];
      };

      bar.waybar = {
        enable = true;
        modules = {
          left = [
            "custom/launcher"
            "wlr/taskbar"
            "custom/launcher"
            "hyprland/workspaces"
          ];
          center = [
            "clock"
          ];
          right = [
            "temperature"
            "cpu"
            "memory"
            "network"
            "custom/powermenu"
          ];
        };
      };
    };
  };

  shellOptions = {
    enable = true;
    shell = {
      tmux.enable = true;
    };
  };

  development = {
    enable = true;
    sdk = {
      enable = false;
    };
    editors = {
      zed.enable = true;
      vscode.enable = true;
      neovim.enable = true;

      jetbrains = {
        enable = true;
        rider = true;
        webstorm = true;
      };
    };
  };
}
