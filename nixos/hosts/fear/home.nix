{
  inputs,
  pkgs,
  username,
  ...
}:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ../../modules/home
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.nh = {
    enable = true;
  };

  home.packages = with pkgs; [
    insync
    insync-nautilus
    vlc
    discord
    spotify-player
    tauon
    strawberry
    owncloud-client
  ];

  browsers = {
    enable = true;
    firefox.enable = true;
    chrome.enable = true;
  };

  rofi.enable = true;

  shellOptions = {
    enable = true;
    shell = {
      tmux.enable = true;
    };
  };

  # Settings for this machine
  windowManager = {
    wayland = {
      enable = true;

      hyprland = {
        enable = true;
        monitors = [
          "DP-1, 3440x1440@164.90, 0x0, 1, bitdepth, 10, vrr, 3"
        ];
        exec-once = [
          "hyprctl dispatch dpms off DP-2"
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
            "wireplumber"
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

  development = {
    enable = true;
    sdk = {
      enable = true;
    };
    tools = {
      enable = true;
      enableCli = true;
      enableGui = true;
    };
    git.enable = true;
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
