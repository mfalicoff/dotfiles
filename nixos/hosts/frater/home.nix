{
  inputs,
  pkgs,
  username,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
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
    # insync
    # insync-nautilus
    # _1password-gui
    # _1password-cli
    # vlc
  ];

  development = {
    enable = true;
    sdk = {
      enable = false;
    };
    editors = {
      zed.enable = true;
      vscode.enable = true;
      neovim.enable = true;

      # jetbrains = {
      #   enable = true;
      #   rider = true;
      #   webstorm = true;
      # };
    };
  };
}
