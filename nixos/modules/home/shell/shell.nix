{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.shellOptions;
in {
  options.shellOptions.shell = {
    enable = mkEnableOption "Enable Shell";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      pure-prompt
      thefuck
      fzf
      ripgrep
      neofetch
      btop
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

    home.sessionVariables = {
      EDITOR = "nvim";
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

      initExtra = ''
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
          "thefuck"
          "azure"
          "bun"
          "docker"
          "fzf"
        ];
      };

      shellAliases = {
        k = "kubectl";
        ll = "ls -l";
      };
    };
  };
}
