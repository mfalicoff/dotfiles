{
  inputs,
  pkgs,
  username,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    inputs.mac-app-util.homeManagerModules.default
    ../../modules/home
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.nh = {
    enable = true;
  };

  home.packages = with pkgs; [
    spotify-player
  ];

  browsers = {
    enable = true;
    firefox.enable = false; # using brew because it can integrate with 1password
    chrome.enable = false;
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
      zed.enable = false;
      vscode.enable = true;
    };
  };
}
