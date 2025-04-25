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
    calibre
  ];

  # Settings for this machine
  windowManager.hyprland = {
    enable = true;
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
