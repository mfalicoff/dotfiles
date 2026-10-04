{ lib, pkgs, username, ... }:
{
  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
    packages = with pkgs; [
      android-tools
      argocd
      bun
      dockutil
      flutter
      gh
      git-filter-repo
      go
      nodejs
      opencode
      openjdk
      sops
      talosctl
      tailscale
      television
      terraform
    ];
  };

  programs.home-manager.enable = true;

  # Homebrew is installed outside the Nix profile on Apple Silicon. Restore
  # its shell environment for login shells without failing if Brew is absent.
  programs.zsh.profileExtra = ''
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$('/opt/homebrew/bin/brew' shellenv)"
    fi
  '';

  xdg.configFile."television".source = ./config/television;

  development = {
    enable = true;
    # The Darwin system profile already manages dotnet-sdk through Homebrew.
    sdk.enable = false;
    tools = {
      enable = true;
      enableCli = true;
      # GitKraken and the other GUI development apps are managed by Homebrew
      # on Darwin.
      enableGui = false;
    };
    git = {
      enable = true;
      enableDelta = false;
      enableLfs = true;
    };
    editors = {
      enable = false;
      neovim.enable = false;
    };
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
    shell = {
      tmux.enable = false;
    };
  };

  home.activation.showLibrary = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/chflags nohidden "$HOME/Library"
  '';
}
