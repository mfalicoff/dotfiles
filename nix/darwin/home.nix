{ config, lib, pkgs, username, ... }:
{
  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
    sessionVariables = {
      EDITOR = "nvim";
      XDG_PICTURES_DIR = "$HOME/screenshots";
      FZF_CTRL_R_OPTS = "--bind 'enter:accept'";
    };
    packages = with pkgs; [
      age
      android-tools
      argocd
      azure-cli
      btop
      bun
      delta
      dockutil
      eza
      flutter
      gh
      git-filter-repo
      git-lfs
      go
      just
      jq
      k9s
      kubectl
      lazydocker
      lazygit
      neovim
      nodejs
      opencode
      openjdk
      pure-prompt
      ripgrep
      sops
      talosctl
      tailscale
      television
      terraform
    ];
  };

  programs.home-manager.enable = true;

  # Home Manager owns these files. Existing user copies are backed up with
  # the pre-nix suffix during activation.
  home.file.".gitconfig".source = ./config/gitconfig;
  # tmux checks ~/.tmux.conf before the XDG file generated below. Replace the
  # old TPM configuration with a small redirect to the Home Manager config.
  home.file.".tmux.conf".text = ''
    source-file ${config.xdg.configHome}/tmux/tmux.conf
  '';
  xdg.configFile."ghostty/config".source = ./config/ghostty/config;
  xdg.configFile."television".source = ./config/television;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
      export PATH="/etc/profiles/per-user/${username}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"
      export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
    '';
    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "azure" "bun" "docker" "fzf" ];
    };
    shellAliases = {
      k = "kubectl";
      ll = "eza -l --icons=auto --git";
      ls = "eza --icons=auto";
      ndev = "nix develop --command zsh";
    };
    initContent = ''
      export PATH="$HOME/.local/bin:$PATH"
      autoload -U promptinit; promptinit
      prompt pure
      setopt NO_AUTO_LIST
      setopt NO_MENU_COMPLETE
      ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&|'
      export ZSH_AUTOSUGGEST_STRATEGY=(history)
      if [[ -z "$TMUX" ]]; then
        tmux attach 2>/dev/null || tmux
      fi
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      nord
      vim-tmux-navigator
      weather
    ];
    extraConfig = ''
      setw -g pane-base-index 1
      set -g default-terminal "screen-256color"
    '';
  };

  home.activation.showLibrary = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/chflags nohidden "$HOME/Library"
  '';
}
