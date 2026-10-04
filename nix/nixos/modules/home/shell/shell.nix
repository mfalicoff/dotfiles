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
      pure-prompt
      fzf
      ripgrep
      neofetch
      btop
      zsh-autosuggestions
      zsh-autocomplete
    ];

    programs.alacritty = {
      enable = true;
      settings = {
        window = {
          decorations = "Buttonless";
          blur = true;
          padding = {
            x = 10;
            y = 10;
          };
        };
      };
    };

    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        window_padding_width = 10;
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
        if [[ -z "$TMUX" ]]; then
          tmux attach || tmux
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
