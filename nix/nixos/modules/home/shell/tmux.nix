{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.shellOptions;
  bundledPlugins = {
    catppuccin = {
      plugin = pkgs.tmuxPlugins.catppuccin;
      extraConfig = ''
        set -g @catppuccin_flavor "mocha"
        set -g @catppuccin_window_status_style "rounded"
      '';
    };
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
      prefix = "C-Space";
      keyMode = "vi";
      mouse = true;
      terminal = "tmux-256color";
      sensibleOnTop = true;
      extraConfig = ''
        set -as terminal-overrides ",xterm*:Tc"
        set -g focus-events on
        set -g renumber-windows on
        setw -g pane-base-index 1
        set -g status-position top

        # Vim-style pane navigation.
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Navigate panes and windows without the prefix key.
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D
        bind -n S-Left previous-window
        bind -n S-Right next-window
        bind -n M-H previous-window
        bind -n M-L next-window

        # Keep new panes in the current directory.
        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        # Vi-style copy mode with OSC 52 clipboard integration.
        set -s set-clipboard on
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      ''
      + cfg.shell.tmux.advanced.extraConfig;
    };

    programs.zsh.initContent = ''
      # Reuse an existing tmux session or create one for interactive shells.
      if [[ -o interactive && -t 1 && -z "$TMUX" ]]; then
        tmux attach-session 2>/dev/null || tmux new-session
      fi
    '';

    home.sessionVariables = lib.optionalAttrs cfg.shell.tmux.tmuxinator {
      TMUXINATOR_CONFIG = "${config.home.homeDirectory}/configuration/tmuxinator";
    };
  };
}
