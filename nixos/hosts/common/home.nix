{pkgs, ...}: {
  home.packages = with pkgs; [
    calibre
    discord
    google-chrome
    spotify-player
  ];

  browsers = {
    enable = true;
    firefox.enable = true;
  };

  shellOptions = {
    enable = true;
    shell = {
      tmux.enable = true;
    };
  };
}
