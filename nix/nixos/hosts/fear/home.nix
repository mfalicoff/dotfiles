{
  inputs,
  pkgs,
  username,
  ...
}:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
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
    (pkgs.affine.override {
      # electron_35 = pkgs.electron;
    })
    insync
    insync-nautilus
    vlc
    discord
    spotify-player
    tauon
    strawberry
    opencloud-desktop
  ];

  browsers = {
    enable = true;
    firefox.enable = true;
    zen.enable = true;
    chrome.enable = true;
  };
  stylix.targets.zen-browser.enable = false;

  rofi.enable = true;

  shellOptions = {
    enable = true;
    zsh.enable = true;
    terminal.enable = true;
    navigation.enable = true;
    monitoring.enable = true;
    tmux.enable = true;
  };

  # Settings for this machine
  windowManager = {
    enable = true;
    wayland = {
      enable = true;

      hyprland = {
        enable = true;
        monitors = [
          "DP-1, 3440x1440@164.90, 0x0, 1, bitdepth, 10, vrr, 3"
        ];
        exec-once = [
          "hyprctl dispatch dpms off DP-2"
          "clipse -listen"
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
      c.enable = true;
      python.enable = true;
      dotnet.enable = true;
    };
    editors = {
      enable = true;
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
