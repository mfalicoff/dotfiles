{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.shellOptions.zsh;
in {
  options.shellOptions.zsh = {
    enable = lib.mkEnableOption "Zsh with completion, plugins, and Pure prompt";
    extraPlugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional Oh My Zsh plugins";
    };
    shellAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Additional or overriding shell aliases";
    };
    atuin.enable = lib.mkEnableOption "Atuin shell history search and sync";
    initContent = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional Zsh initialization";
    };
  };
  config = lib.mkIf (config.shellOptions.enable && cfg.enable) {
    home.packages = [pkgs.pure-prompt];
    programs.atuin = lib.mkIf cfg.atuin.enable {
      enable = true;
      enableZshIntegration = true;
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
      initContent =
        ''
          autoload -U promptinit; promptinit
          prompt pure
        ''
        + cfg.initContent;
      oh-my-zsh = {
        enable = true;
        plugins =
          ["git"]
          ++ lib.optionals (config.development.enable && config.development.containers.enable) ["docker" "podman"]
          ++ lib.optional (config.development.enable && config.development.cloud.enable) "azure"
          ++ lib.optional (config.shellOptions.navigation.enable) "fzf"
          ++ cfg.extraPlugins;
      };
      shellAliases =
        {
          k = "kubectl";
          ll = "ls -l";
          ndev = "nix develop --command zsh";
        }
        // cfg.shellAliases;
    };
  };
}
