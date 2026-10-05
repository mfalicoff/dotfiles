{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.shellOptions.zsh;
in
{
  options.shellOptions.zsh = {
    enable = lib.mkEnableOption "Zsh with completion, plugins, and Pure prompt";
    extraPlugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional Oh My Zsh plugins";
    };
    shellAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Additional or overriding shell aliases";
    };
    initContent = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional Zsh initialization";
    };
  };
  config = lib.mkIf (config.shellOptions.enable && cfg.enable) {
    home.packages = with pkgs; [
      pure-prompt
      zsh-autosuggestions
      zsh-autocomplete
    ];
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
      ''
      + cfg.initContent;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "azure"
          "bun"
          "docker"
          "fzf"
        ]
        ++ cfg.extraPlugins;
      };
      shellAliases = {
        k = "kubectl";
        ll = "ls -l";
        ndev = "nix develop --command zsh";
      }
      // cfg.shellAliases;
    };
  };
}
