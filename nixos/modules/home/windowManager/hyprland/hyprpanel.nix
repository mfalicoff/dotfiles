{
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.windowManager.wayland.bar.hyprpanel;
in {
  imports = [
    inputs.hyprpanel.homeManagerModules.hyprpanel
  ];

  options.windowManager.wayland.bar.hyprpanel = {
    enable = mkEnableOption "Enable HyprPanel configuration";
  };

  config = mkIf cfg.enable {
    # HyprPanel configuration
    programs.hyprpanel = {
      # Enable the module
      enable = true;

      # Automatically restart HyprPanel with systemd
      systemd.enable = true;

      # Add HyprPanel to Hyprland exec-once
      hyprland.enable = true;

      # Fix the overwrite issue with HyprPanel
      overwrite.enable = true;

      # Override specific theme elements
      override = {
        theme.bar.menus.text = "#123ABC";
      };

      # Configure panel settings
      settings = {
        theme = {
          name = "catppuccin_frappe";
          font = {
            name = "CaskaydiaCove NF";
            size = "16px";
          };
          bar.transparent = true;
        };

        # Configure bar layouts for monitors
        layout = {
          "bar.layouts" = {
            "0" = {
              left = ["dashboard" "workspaces"];
              middle = ["media"];
              right = ["battery" "network" "bluetooth" "clock" "volume" "systray" "notifications"];
            };
          };
        };

        # Configure bar settings
        bar = {
          autoHide = "fullscreen";
          launcher.autoDetectIcon = true;
          workspaces.show_icons = true;
        };

        menus = {
          clock = {
            time = {
              military = true;
              hideSeconds = true;
            };
            weather.unit = "metric";
          };
          dashboard.directories.enabled = false;
          dashboard.stats.enable_gpu = true;
        };
      };
    };
  };
}
