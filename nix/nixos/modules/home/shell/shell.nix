{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.shellOptions.shell;
  bundledPackages = {
    fzf = pkgs.fzf;
    ripgrep = pkgs.ripgrep;
    fastfetch = pkgs.fastfetch;
    btop = pkgs.btop;
    purePrompt = pkgs.pure-prompt;
    zshAutosuggestions = pkgs.zsh-autosuggestions;
    zshAutocomplete = pkgs.zsh-autocomplete;
  };
  bundledZshPlugins = [
    "git"
    "azure"
    "bun"
    "docker"
    "fzf"
  ];
  toggle =
    name:
    lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the bundled ${name} shell feature";
    };
in
{
  options.shellOptions.shell = {
    enable = lib.mkEnableOption "shell configuration";
    packages = builtins.mapAttrs (name: _: toggle name) bundledPackages;
    features = {
      ghostty = toggle "Ghostty";
      zsh = toggle "Zsh";
      eza = toggle "eza";
      yazi = toggle "Yazi";
      skim = toggle "Skim";
    };
    zshPlugins = builtins.listToAttrs (
      map (name: {
        inherit name;
        value = toggle name;
      }) bundledZshPlugins
    );
    ghosttySettings = {
      nordTheme = toggle "Nord theme";
      padding = toggle "Ghostty window padding";
      transparency = toggle "Ghostty transparency";
    };
    advanced = {
      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Additional shell packages";
      };
      zshPlugins = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional Oh My Zsh plugins";
      };
      shellAliases = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Additional or overriding shell aliases";
      };
      zshInit = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Additional Zsh initialization code";
      };
      ghosttySettings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        description = "Additional or overriding Ghostty settings";
      };
    };
  };
  config = lib.mkIf (config.shellOptions.enable && cfg.enable) {
    home.packages =
      builtins.attrValues (lib.filterAttrs (name: _: cfg.packages.${name}) bundledPackages)
      ++ cfg.advanced.extraPackages;

    programs.ghostty = lib.mkIf cfg.features.ghostty {
      enable = true;
      package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
      settings = lib.recursiveUpdate (
        {
          font-size = 15;
          font-family = "JetBrainsMono Nerd Font";
        }
        // lib.optionalAttrs cfg.ghosttySettings.nordTheme {
          theme = "Nord";
        }
        // lib.optionalAttrs cfg.ghosttySettings.padding {
          window-padding-x = 10;
          window-padding-y = 10;
        }
        // lib.optionalAttrs cfg.ghosttySettings.transparency {
          background-opacity = 0.95;
        }
      ) cfg.advanced.ghosttySettings;
    };

    home.sessionVariables = {
      EDITOR = "nvim";
      XDG_PICTURES_DIR = "~/screenshots";
    };

    programs.zsh = lib.mkIf cfg.features.zsh {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = cfg.packages.zshAutosuggestions;
      syntaxHighlighting.enable = true;

      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };

      initContent =
        (lib.optionalString cfg.packages.purePrompt ''
          autoload -U promptinit; promptinit
          prompt pure
        '')
        + cfg.advanced.zshInit;

      oh-my-zsh = {
        enable = true;
        plugins =
          builtins.filter (name: cfg.zshPlugins.${name}) bundledZshPlugins ++ cfg.advanced.zshPlugins;
      };

      shellAliases = {
        k = "kubectl";
        ll = "ls -l";
        ndev = "nix develop --command zsh";
      }
      // cfg.advanced.shellAliases;
    };

    programs = {
      eza = lib.mkIf cfg.features.eza {
        enable = true;
        git = true;
        icons = "auto";
        enableZshIntegration = true;
      };

      # terminal file manager
      yazi = lib.mkIf cfg.features.yazi {
        enable = true;
        enableZshIntegration = true;
        settings = {
          manager = {
            show_hidden = true;
            sort_dir_first = true;
          };
        };
      };

      # skim provides a single executable: sk.
      # Basically anywhere you would want to use grep, try sk instead.
      skim = lib.mkIf cfg.features.skim {
        enable = true;
        enableBashIntegration = true;
      };
    };
  };
}
