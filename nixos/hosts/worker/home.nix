{
  inputs,
  pkgs,
  username,
  ...
}: {
  imports = [
    inputs.textfox.homeManagerModules.default
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
    _1password-cli
  ];

  # Settings for this machine
  development = {
    enable = true;
    tools = {
      enable = true;
    };
    editors = {
      neovim.enable = true;
    };
  };
}
