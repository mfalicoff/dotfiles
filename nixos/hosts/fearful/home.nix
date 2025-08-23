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

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    raycast
    discord
    spotify-player
  ];

  browsers = {
    enable = true;
    firefox.enable = false; # using brew because it can integrate with 1password
    chrome.enable = true;
  };

  shellOptions = {
    enable = true;
    shell = {
      tmux.enable = true;
    };
  };

  development = {
    enable = true;
    tools = {
      enable = true;
      enableCli = true;
      enableGui = false;
    };
    git.enable = true;
    sdk = {
      enable = false;
    };
    editors = {
      zed.enable = true;
      vscode.enable = true;
    };
  };
}
