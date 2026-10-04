{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.shellOptions;
in
{
  options.shellOptions.shell = {
    enable = mkEnableOption "Enable Shell";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fzf
      ripgrep
      fastfetch
      btop
      pure-prompt
      tuios
      zsh-autosuggestions
      zsh-autocomplete
    ];

    programs.ghostty = {
      enable = true;
      package = pkgs.ghostty-bin;
      settings = {
        theme = "Nord";
        font-size = 15;
        font-family = "JetBrainsMono Nerd Font";
        window-padding-x = 10;
        window-padding-y = 10;
        background-opacity = 0.95;
      };
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      XDG_PICTURES_DIR = "~/screenshots";
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };

      initContent = ''
        autoload -U promptinit; promptinit
        prompt pure
        # TUIOS sets TERM_PROGRAM for shells it starts. Avoid launching a
        # nested TUIOS instance in every new window.
        if [[ "$TERM_PROGRAM" != "TUIOS" ]]; then
          exec tuios
        fi
      '';

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "azure"
          "bun"
          "docker"
          "fzf"
        ];
      };

      shellAliases = {
        k = "kubectl";
        ll = "ls -l";
        ndev = "nix develop --command zsh";
      };
    };

    programs = {
      eza = {
        enable = true;
        git = true;
        icons = "auto";
        enableZshIntegration = true;
      };

      # terminal file manager
      yazi = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          manager = {
            show_hidden = true;
            sort_dir_first = true;
          };
        };
      };

      # skim provides a single executable: sk.
      # Basically anywhere you would want to use grep, try sk instead.
      skim = {
        enable = true;
        enableBashIntegration = true;
      };
    };
  };
}
