{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.development.editors.zed;
in {
  options.development.editors.zed = {
    enable = mkEnableOption "Enable Zed Editor";
    extensions = mkOption {
      type = types.listOf types.str;
      default = ["nix" "toml" "elixir" "make" "catppuccin" "catppuccin-icons" "just"];
      description = "Extensions to install for Zed";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nil
      nixd
      alejandra
      omnisharp-roslyn
    ];

    programs.zed-editor = {
      enable = true;
      extensions = cfg.extensions;
      extraPackages = [];
      ## everything inside of these brackets are Zed options.
      userSettings = {
        assistant = {
          enabled = false;
        };
        node = {
          path = lib.getExe pkgs.nodejs;
          npm_path = lib.getExe' pkgs.nodejs "npm";
        };
        hour_format = "hour24";
        auto_update = false;
        terminal = {
          alternate_scroll = "off";
          blinking = "off";
          copy_on_select = false;
          dock = "bottom";
          detect_venv = {
            on = {
              directories = [".env" "env" ".venv" "venv"];
              activate_script = "default";
            };
          };
          env = {
            TERM = "alacritty";
          };
          font_family = "FiraCode Nerd Font";
          font_features = null;
          font_size = null;
          line_height = "comfortable";
          option_as_meta = false;
          button = false;
          shell = "system";
          toolbar = {
            title = true;
          };
          working_directory = "current_project_directory";
        };
        lsp = {
          rust-analyzer = {
            binary = {
              path_lookup = true;
            };
          };
          nix = {
            binary = {
              path_lookup = true;
            };
          };
          elixir-ls = {
            binary = {
              path_lookup = true;
            };
            settings = {
              dialyzerEnabled = true;
            };
          };
        };
        languages = {
          "Elixir" = {
            language_servers = ["!lexical" "elixir-ls" "!next-ls"];
            format_on_save = {
              external = {
                command = "mix";
                arguments = ["format" "--stdin-filename" "{buffer_path}" "-"];
              };
            };
          };
          "HEEX" = {
            language_servers = ["!lexical" "elixir-ls" "!next-ls"];
            format_on_save = {
              external = {
                command = "mix";
                arguments = ["format" "--stdin-filename" "{buffer_path}" "-"];
              };
            };
          };
          Nix = {
            language_servers = ["nixd"];
            formatter = {
              external = {
                command = "alejandra";
                arguments = ["-q" "-"];
              };
            };
          };
        };
        vim_mode = false;
        load_direnv = "shell_hook";
        base_keymap = "JetBrains";
        icon_theme = mkForce "Catppuccin Frappé";
        show_whitespaces = "all";
        files = {
          excludeDirs = [
            ".cargo"
            ".direnv"
            ".git"
            "node_modules"
            "target"
            "bin"
            "obj"
          ];
        };
      };
    };
  };
}
