{
  inputs,
  username,
  ...
}: {
  imports = [
    inputs.textfox.homeManagerModules.default
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

  shellOptions = {
    enable = true;
    shell = {
      tmux.enable = true;
    };
  };

  # Settings for this machine
  browsers.enable = false;
  development = {
    enable = true;
    tools = {
      enable = true;
      enableCli = true;
      enableGui = false;
    };
    editors = {
      neovim.enable = true;
    };
  };
}
