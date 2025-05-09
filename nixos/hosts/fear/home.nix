{
  inputs,
  pkgs,
  username,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    inputs.textfox.homeManagerModules.default
    ../common/home.nix
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
    _1password-gui
    _1password-cli
    vlc
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
