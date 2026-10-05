{
  inputs,
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

  shellOptions = {
    enable = true;
    zsh.enable = true;
    terminal.enable = true;
    navigation.enable = true;
    monitoring.enable = true;
    tmux.enable = true;
  };

  # Settings for this machine
  browsers.enable = false;
  development = {
    enable = true;
    git.enable = true;
    cloud.enable = true;
    containers.enable = true;
    kubernetes.enable = true;
    nix.enable = true;
    secrets.enable = true;
    tools.enable = true;
    desktop.enable = false;
    environment.enable = true;
    languages = {
      c.enable = true;
      python.enable = true;
      dotnet.enable = false;
    };
    editors = {
      enable = true;
      neovim.enable = true;
    };
  };
}
