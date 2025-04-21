{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.windowManager.wayland.bar.waybar;
in {
  options.windowManager.wayland.bar.waybar = {
    enable = mkEnableOption "Enable Waybar configuration";

    modules = {
      left = mkOption {
        type = types.listOf types.str;
        default = [
          "custom/launcher"
          "wlr/taskbar"
          "hyprland/workspaces"
        ];
        description = "Modules to display on the left side of the bar";
      };

      center = mkOption {
        type = types.listOf types.str;
        default = [
          "clock"
        ];
        description = "Modules to display in the center of the bar";
      };

      right = mkOption {
        type = types.listOf types.str;
        default = [
          "temperature"
          "memory"
          "cpu"
          "group/traydrawer"
          "network"
          "wireplumber"
          "battery"
          "idle_inhibitor"
          "custom/osk"
          "hyprland/language"
          "custom/powermenu"
        ];
        description = "Modules to display on the right side of the bar";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;

      systemd = {
        enable = true; # This makes Waybar start as a systemd user service
        target = "hyprland-session.target"; # This binds Waybar to Hyprland
      };

      settings = [
        {
          modules-left = cfg.modules.left;
          modules-center = cfg.modules.center;
          modules-right = cfg.modules.right;

          "wlr/taskbar" = {
            format = "{icon}";
            icon-size = 14;
            tooltip = false;
            on-click = "activate";
            on-click-middle = "close";
            ignore-list = [
              # "kitty"
            ];
          };

          wireplumber = {
            scroll-step = 1;
            format = "{icon} {volume}%";
            format-muted = "󰖁 0%";
            format-icons = {
              default = ["" "" ""];
            };
            on-click = "swayosd-client --output-volume mute-toggle";
            on-scroll-down = "swayosd-client --output-volume +1";
            on-scroll-up = "swayosd-client --output-volume -1";
            tooltip = false;
          };

          clock = {
            interval = 1;
            format = "{:%R  %A %b %d}";
            tooltip = true;
            tooltip-format = "<tt>{calendar}</tt>";
          };

          mpris = {
            format = "DEFAULT: {player_icon} {dynamic}";
            format-paused = "DEFAULT: {status_icon} <i>{dynamic}</i>";
            player-icons = {
              default = "▶";
              mpv = "🎵";
            };
            status-icons = {
              paused = "⏸";
            };
          };

          temperature = {
            thermal-zone = 0; # 5 for surface, TODO make an option
            critical-threshold = 100;
            interval = 5;
            format-icons = ["" "" "" "" "" "󰸁"];
            format = "{icon} {temperatureC}󰔄";
          };

          memory = {
            interval = 1;
            format = "󰍛 {percentage:02}%";
            states = {
              warning = 85;
            };
          };

          cpu = {
            interval = 1;
            format = "󰻠 {usage:02}%";
            states = {
              warning = 95;
            };
          };

          network = {
            format-disconnected = "󰯡 Disconnected";
            format-ethernet = "󰒢 Connected!";
            format-linked = "󰖪 {essid} (No IP)";
            format-wifi = "󰖩  {essid}";
            interval = 1;
            tooltip = false;
          };
          "custom/osk" = let
            keyboard = "wvkbd-mobintl";
            flags = "--landscape-layers simple,special,emoji -L 200 ";
          in {
            format-alt = "󰌐"; # They are inverted
            format = "󰌌";
            tooltip = false;
            # https://github.com/Alexays/Waybar/issues/1850
            on-click = "sleep 0.1 && toggle ${keyboard} ${flags}";
          };

          "custom/powermenu" = {
            format = "";
            tooltip = false;
            on-click = "wlogout";
          };

          tray = {
            icon-size = 14;
            # show-passive-items = true;
            spacing = 5;
          };

          battery = {
            interval = 10;
            full-at = 99;
            on-click = "toggle nwg-bar -t power.json";
            states = {
              "good" = 90;
              "warning" = 30;
              "critical" = 15;
            };
            format = "{icon}   {capacity}%";
            format-charging = "󱐋 {capacity}%";
            format-plugged = " {capacity}%";
            # format-full = ""; // An empty format will hide the module
            format-icons = ["" "" "" "" ""];
            tooltip = false;
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "󰒳";
              deactivated = "󰒲";
            };
          };

          "hyprland/workspaces" = {
            active-only = false;
            all-outputs = true;
            disable-scroll = false;
            on-scroll-up = "hyprctl dispatch r+1";
            on-scroll-down = "hyprctl dispatch r-1";
            format = "{name}: {icon}";
            on-click = "activate";
            format-icons = {
              urgent = "";
              active = "";
              default = "󰧞";
            };
            sort-by-number = true;
          };
        }
      ];

      style = ''

        * {
          font-family: "JetBrainsMono Nerd Font";
          font-size: 16px;
        }

        window#waybar {
          background-color: rgba(0, 0, 0, 0);
          border-radius: 13px;
          transition-property: background-color;
          transition-duration: .5s;
        }

        button {
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -3px transparent;
          /* Avoid rounded borders under each button name */
          border: none;
          border-radius: 0;
        }

        /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
        button:hover {
          background: inherit;
          box-shadow: inset 0 -3px #ffffff;
        }

        /* you can set a style on hover for any module like this */
        #pulseaudio:hover {
          background-color: @surface2;
        }

        #workspaces button {
          padding: 0 5px;
          background-color: transparent;
          color: #ffffff;
        }


        #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
        }

        #workspaces button.focused {
          background-color: @lavender;
          box-shadow: inset 0 -3px #ffffff;
        }

        #workspaces button.urgent {
          background-color: #eb4d4b;
        }

        #mode {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #temperature,
        #network,
        #pulseaudio {
          padding: 0 10px;
        }

        #pulseaudio {
          color: @maroon;
        }

        #network {
          color: @yellow;
        }

        #temperature {
          color: @sky;
        }

        #battery {
          color: @green;
        }

        #clock {
          color: @flamingo;
        }

        #window {
          color: @rosewater;
        }

        .modules-right,
        .modules-left,
        .modules-center {
          background-color: @base;
          border-radius: 15px;
        }

        .modules-right {
          padding: 0 10px;
        }

        .modules-left {
          padding: 0 20px;
        }

        .modules-center {
          padding: 0 10px;
        }

        #battery.charging,
        #battery.plugged {
          color: @sapphire;
        }

        @keyframes blink {
          to {
            color: #000000;
          }
        }

        /* Using steps() instead of linear as a timing function to limit cpu usage */
        #battery.critical:not(.charging) {
          background-color: #f53c3c;
          color: #ffffff;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: steps(12);
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        label:focus {
          background-color: #000000;
        }

        #pulseaudio.muted {
          color: @text;
        }
      '';
    };
  };
}
