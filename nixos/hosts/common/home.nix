{pkgs, ...}: {
  home.packages = with pkgs; [
    calibre
    discord
    firefox
    google-chrome
    spotify-player
  ];

  shellOptions = {
    enable = true;
    shell = {
      tmux.enable = true;
    };
  };
}
