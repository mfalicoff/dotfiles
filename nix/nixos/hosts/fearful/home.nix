{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./plist.nix
    ../darwin/common-home.nix
    ../../modules/home
  ];

  home.packages = with pkgs; [
    whatsapp-for-mac
  ];

  ai = {
    enable = true;
    chatgpt.enable = true;
    codex.enable = true;
    pi.enable = true;
  };

  xdg.configFile."television".source = ../darwin/config/television;
  browsers = {
    enable = true;
    zen.enable = true;
  };
  stylix.targets.zen-browser = {
    enable = true;
    profileNames = ["default"];
  };
  windowManager = {
    enable = true;
    omniwm.enable = true;
  };

  profiles.devWorkstation.enable = true;

  development = {
    containers.desktop.enable = true;
    desktop.enable = true;
    mobile.enable = true;
    languages = {
      dotnet = {
        enable = true;
        rider.enable = true;
      };
      java.enable = true;
    };
    editors.zed.enable = true;
  };

  # Keep the additional Git settings from the former Darwin .gitconfig while
  # letting the shared development module own the generated Git config.
  programs.git.settings = {
    user.signingKey = "~/.ssh/id_ed25519.pub";
    commit.gpgSign = true;
    gpg.format = "ssh";
    merge.conflictstyle = "diff3";
    diff.colorMoved = "default";
    core.pager = "delta";
    interactive.diffFilter = "delta --color-only";
  };

  programs.delta.options = {
    navigate = true;
    light = false;
  };

  shellOptions = {
    enable = true;
    zsh.enable = true;
    terminal.enable = true;
    navigation.enable = true;
    monitoring.enable = true;
    tmux.enable = true;
  };

  home.activation.showLibrary = lib.hm.dag.entryAfter ["writeBoundary"] ''
    /usr/bin/chflags nohidden "$HOME/Library"
  '';
}
