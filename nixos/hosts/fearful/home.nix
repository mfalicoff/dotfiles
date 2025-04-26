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

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    raycast
  ];

  windowManager = {
    aerospace.enable = true;
  };

  development = {
    enable = true;
    sdk = {
      enable = false;
    };
    editors = {
      zed.enable = true;
      vscode.enable = true;
    };
  };
}
