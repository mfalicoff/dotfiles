{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.shellOptions;
in {
  options.shellOptions.shell.tmux = {
    enable = mkEnableOption "Enable tmux";
  };

  config = mkIf (cfg.shell.enable && cfg.shell.tmux.enable) {
    home.packages = with pkgs; [
      tmuxinator
    ];

    programs.tmux = {
      enable = true;
      plugins = [
        pkgs.tmuxPlugins.nord
        pkgs.tmuxPlugins.vim-tmux-navigator
        pkgs.tmuxPlugins.weather
      ];
      baseIndex = 1;
      extraConfig = ''
        set -g mouse on
        set -g default-terminal "screen-256color"
        setw -g pane-base-index 1
      '';
    };

    home.sessionVariables = {
      TMUXINATOR_CONFIG = "/home/mazilious/configuration/tmuxinator";
    };
  };
}
