{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.shellOptions;
  bundledPlugins = {
    nord = pkgs.tmuxPlugins.nord;
    vimNavigator = pkgs.tmuxPlugins.vim-tmux-navigator;
    weather = pkgs.tmuxPlugins.weather;
  };
in
{
  options.shellOptions.shell.tmux = {
    enable = lib.mkEnableOption "tmux";
    tmuxinator = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install tmuxinator and set its configuration directory";
    };
    plugins = builtins.mapAttrs (
      name: _:
      lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable the bundled ${name} tmux plugin";
      }
    ) bundledPlugins;
    advanced = {
      plugins = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Additional tmux plugin packages";
      };
      extraConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Additional tmux configuration";
      };
    };
  };

  config = lib.mkIf (cfg.enable && cfg.shell.enable && cfg.shell.tmux.enable) {
    home.packages = lib.optional cfg.shell.tmux.tmuxinator pkgs.tmuxinator;

    programs.tmux = {
      enable = true;
      plugins =
        builtins.attrValues (lib.filterAttrs (name: _: cfg.shell.tmux.plugins.${name}) bundledPlugins)
        ++ cfg.shell.tmux.advanced.plugins;
      baseIndex = 1;
      extraConfig = ''
        set -g mouse on
        set -g default-terminal "screen-256color"
        setw -g pane-base-index 1
      ''
      + cfg.shell.tmux.advanced.extraConfig;
    };

    home.sessionVariables = lib.optionalAttrs cfg.shell.tmux.tmuxinator {
      TMUXINATOR_CONFIG = "/home/mazilious/configuration/tmuxinator";
    };
  };
}
