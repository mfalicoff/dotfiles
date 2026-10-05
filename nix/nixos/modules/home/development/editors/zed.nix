{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.development.editors.zed;
  bundledExtensions = {
    nix = "nix";
    toml = "toml";
    elixir = "elixir";
    make = "make";
    catppuccin = "catppuccin";
    catppuccinIcons = "catppuccin-icons";
    just = "just";
  };
in {
  options.development.editors.zed = {
    enable = mkEnableOption "Enable Zed Editor";
    extensions =
      builtins.mapAttrs (
        name: _:
          mkOption {
            type = types.bool;
            default = true;
            description = "Install the bundled ${name} Zed extension";
          }
      )
      bundledExtensions;
    settings = {
      assistant = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Zed's assistant";
      };
      autoUpdate = mkOption {
        type = types.bool;
        default = false;
        description = "Allow Zed to update itself";
      };
      vimMode = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Vim key bindings";
      };
    };
    advanced = {
      extensions = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional Zed extension IDs";
      };
      settings = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        description = "Additional or overriding Zed user settings";
      };
    };
  };

  config = mkIf (config.development.enable && config.development.editors.enable && cfg.enable) {
    home.packages = with pkgs; [
      nil
      nixd
      alejandra
      omnisharp-roslyn
    ];

    programs.zed-editor = {
      enable = true;
      extensions =
        builtins.attrValues (lib.filterAttrs (name: _: cfg.extensions.${name}) bundledExtensions)
        ++ cfg.advanced.extensions;
      extraPackages = [];
      ## everything inside of these brackets are Zed options.
      userSettings =
        (lib.recursiveUpdate {
          assistant = {
            enabled = cfg.settings.assistant;
          };
          node = {
            path = lib.getExe pkgs.nodejs;
            npm_path = lib.getExe' pkgs.nodejs "npm";
          };
          journal = {
            hour_format = "hour24";
          };
          auto_update = cfg.settings.autoUpdate;
          terminal = {
            alternate_scroll = "off";
            blinking = "off";
            copy_on_select = false;
            dock = "bottom";
            detect_venv = {
              on = {
                directories = [
                  ".env"
                  "env"
                  ".venv"
                  "venv"
                ];
                activate_script = "default";
              };
            };
            env = {
              TERM = "ghostty";
            };
            font_family = "FiraCode Nerd Font";
            font_features = null;
            font_size = null;
            line_height = "comfortable";
            option_as_meta = false;
            button = false;
            shell = "system";
            toolbar = {
              breadcrumbs = true;
            };
            working_directory = "current_project_directory";
          };
          lsp = {
            elixir-ls = {
              settings = {
                dialyzerEnabled = true;
              };
            };
          };
          languages = {
            "Elixir" = {
              language_servers = [
                "!lexical"
                "elixir-ls"
                "!next-ls"
              ];
              format_on_save = "on";
              formatter = {
                external = {
                  command = "mix";
                  arguments = [
                    "format"
                    "--stdin-filename"
                    "{buffer_path}"
                    "-"
                  ];
                };
              };
            };
            "HEEx" = {
              language_servers = [
                "!lexical"
                "elixir-ls"
                "!next-ls"
              ];
              format_on_save = "on";
              formatter = {
                external = {
                  command = "mix";
                  arguments = [
                    "format"
                    "--stdin-filename"
                    "{buffer_path}"
                    "-"
                  ];
                };
              };
            };
            Nix = {
              language_servers = ["nixd"];
              format_on_save = "on";
              formatter = {
                external = {
                  command = "alejandra";
                  arguments = [
                    "-q"
                    "-"
                  ];
                };
              };
            };
          };
          vim_mode = cfg.settings.vimMode;
          load_direnv = "shell_hook";
          base_keymap = "JetBrains";
          show_whitespaces = "all";
          file_scan_exclusions = [
            "..."
            "**/.cargo"
            "**/.direnv"
            "**/.git"
            "**/node_modules"
            "**/target"
            "**/bin"
            "**/obj"
          ];
        } (removeAttrs cfg.advanced.settings ["icon_theme"]))
        // {
          icon_theme = mkForce (cfg.advanced.settings.icon_theme or "Catppuccin Frappé");
        };
    };
  };
}
