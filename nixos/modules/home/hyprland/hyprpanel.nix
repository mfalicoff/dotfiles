{
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.wm.hyprland.panel;
in {
  imports = [
    inputs.hyprpanel.homeManagerModules.hyprpanel
  ];

  options.wm.hyprland.panel = {
    enable = mkEnableOption "Enable HyprPanel configuration";
  };

  config = mkIf cfg.enable {
    # HyprPanel configuration
    programs.hyprpanel = {
      # Enable the module
      enable = true;

      # Automatically restart HyprPanel with systemd
      # systemd.enable = true;

      # Add HyprPanel to Hyprland exec-once
      hyprland.enable = true;

      # Fix the overwrite issue with HyprPanel
      overwrite.enable = true;

      # Use Catppuccin Frappe theme
      theme = "catppuccin_frappe";

      # Override specific theme elements
      override = {
        theme.bar.menus.text = "#123ABC";
      };

      # Configure bar layouts for monitors
      layout = {
        "bar.layouts" = {
          "0" = {
            left = ["dashboard" "workspaces"];
            middle = ["media"];
            right = ["clock" "volume" "systray" "notifications"];
          };
        };
      };

      # Configure panel settings
      settings = {
        bar.autoHide = "fullscreen";
        bar.launcher.autoDetectIcon = true;
        bar.workspaces.show_icons = true;
        menus.clock = {
          time = {
            military = true;
            hideSeconds = true;
          };
          weather.unit = "metric";
        };
        menus.dashboard.directories.enabled = false;
        menus.dashboard.stats.enable_gpu = true;
        theme.bar.transparent = true;
        theme.font = {
          name = "CaskaydiaCove NF";
          size = "16px";
        };
      };
    };
  };
}
