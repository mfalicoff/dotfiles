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
