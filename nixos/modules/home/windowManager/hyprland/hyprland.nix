{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.windowManager.wayland.hyprland;
in {
  options.windowManager.wayland.hyprland = {
    enable = mkEnableOption "Enable Hyprland window manager configuration";
    monitors = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Monitor configuration";
    };
  };

  config = mkIf cfg.enable {
    # Hyprland configuration
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        # Monitor configuration
        monitor = cfg.monitors;

        # Environment variables
        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];

        # General settings
        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;
          # "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          # "col.inactive_border" = "rgba(595959aa)";
          resize_on_border = false;
          allow_tearing = false;
          layout = "master";
        };

        # Decoration settings
        decoration = {
          rounding = 10;
          active_opacity = 1.0;
          inactive_opacity = 1.0;

          # Shadow settings
          # drop_shadow = true;
          # shadow_range = 4;
          # shadow_render_power = 3;
          # "col.shadow" = "rgba(1a1a1aee)";

          blur = {
            enabled = true;
            size = 3;
            passes = 1;
            vibrancy = 0.1696;
          };
        };

        # Animation settings
        animations = {
          enabled = true;

          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        # Layout settings
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        master = {
          new_status = "slave";
        };

        misc = {
          force_default_wallpaper = -1;
          disable_hyprland_logo = lib.mkForce false;
        };

        # Input settings
        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";

          follow_mouse = 1;
          sensitivity = 0;

          touchpad = {
            natural_scroll = true;
          };
        };

        # Gesture settings
        gestures = {
          workspace_swipe = false;
        };

        # Device-specific settings
        device = {
          name = "epic-mouse-v1";
          sensitivity = -0.5;
        };

        # Window rules
        windowrulev2 = "suppressevent maximize, class:.*";

        # Binds
        binds = {
          workspace_center_on = 1;
        };

        # Define variables
        "$mainMod" = "SUPER";
        "$terminal" = "alacritty";
        "$fileManager" = "nautilus";
        "$menu" = "wofi --show drun";

        # Key bindings
        bind = [
          # Basic controls
          "$mainMod, RETURN, exec, $terminal"
          "$mainMod, C, killactive,"
          "$mainMod, M, exit,"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, V, togglefloating,"
          "$mainMod, R, exec, $menu"
          "$mainMod, P, pseudo," # dwindle
          "$mainMod, J, togglesplit," # dwindle
          "$mainMod, F, fullscreen,"

          # Move focus with mainMod + arrow keys
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          # Vim-style focus
          "$mainMod, h, movefocus, l" # Focus left
          "$mainMod, l, movefocus, r" # Focus right
          "$mainMod, k, movefocus, u" # Focus up
          "$mainMod, j, movefocus, d" # Focus down

          # Switch workspaces
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"

          # Move windows to workspaces
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"

          # Vim-style window movement
          "$mainMod SHIFT, h, movewindow, l" # Move window left
          "$mainMod SHIFT, l, movewindow, r" # Move window right
          "$mainMod SHIFT, k, movewindow, u" # Move window up
          "$mainMod SHIFT, j, movewindow, d" # Move window down

          # Scroll through workspaces
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"

          # Custom application bindings
          "$mainMod, D, exec, rofi -show drun"
          "$mainMod SHIFT, P, exec, wlogout"
        ];

        # Workspace rules
        workspace = [
          "1"
          "2"
          "3"
          "4"
          "5"
          "6"
          "7"
          "8"
          "9"
        ];

        # Move/resize windows with mainMod + mouse
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };
    };

    # Hyprpaper configuration
    services.hyprpaper = {
      enable = true;
      settings = {
        wallpaper = [
          ", /home/mazilious/.config/nixos/hosts/default/wallpapper.jpg"
          ", /home/mazilious/.config/nixos/hosts/default/wallpapper.jpg"
        ];
      };
    };
  };
}
