{
  lib,
  pkgs,
  username,
  ...
}: {
  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
    packages = with pkgs; [
      bun
      dockutil
      gh
      git-filter-repo
      go
      nodejs
      opencode
      openjdk
    ];
  };

  programs.home-manager.enable = true;

  # Homebrew is installed outside the Nix profile. Restore its shell
  # environment for every Zsh session, including non-login terminal shells,
  # without failing if Brew is absent.
  programs.zsh.envExtra = ''
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$('/opt/homebrew/bin/brew' shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$('/usr/local/bin/brew' shellenv)"
    fi
  '';

  xdg.configFile."television".source = ./config/television;

  browsers = {
    enable = true;
    zen.enable = true;
  };
  programs.nh = {
    enable = true;
  };
  stylix.targets.zen-browser = {
    enable = true;
    profileNames = ["default"];
  };

  development = {
    enable = true;
    git = {
      enable = true;
      enableDelta = false;
      enableLfs = true;
    };
    cloud.enable = true;
    containers.enable = true;
    kubernetes.enable = true;
    nix.enable = true;
    secrets.enable = true;
    tools.enable = true;
    desktop.enable = true;
    environment.enable = true;
    mobile.enable = true;
    languages = {
      c.enable = true;
      python.enable = true;
      dotnet.enable = true;
    };
    editors = {
      enable = true;
      jetbrains = {
        enable = true;
        rider = true;
      };
      zed.enable = true;
      neovim.enable = false;
    };
  };

  programs.codex.enable = true;
  programs.discord.enable = true;

  programs.omniwm = {
    enable = true;
    settings = ./config/omniwm/omniwm-settings.toml;
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
