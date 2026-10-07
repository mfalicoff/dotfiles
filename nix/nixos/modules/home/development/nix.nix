{
  config,
  lib,
  pkgs,
  ...
} @ args: let
  cfg = config.development.nix;
  editors = config.development.editors;
  configurationSet =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "darwinConfigurations"
    else "nixosConfigurations";
  flakeExpr = "builtins.getFlake ${builtins.toJSON cfg.completion.flakePath}";
  systemExpr = "(${flakeExpr}).${configurationSet}.${builtins.toJSON cfg.completion.hostName}";
  nixdSettings = {
    nixpkgs.expr = "import (${flakeExpr}).inputs.nixpkgs { system = ${builtins.toJSON pkgs.stdenv.hostPlatform.system}; config.allowUnfree = true; }";
    formatting.command = ["alejandra" "-q"];
    options = {
      system.expr = "${systemExpr}.options";
      home_manager.expr = ''
        let
          flake = ${flakeExpr};
          system = flake.${configurationSet}.${builtins.toJSON cfg.completion.hostName};
          extended = system.extendModules {
            modules = [{
              home-manager.sharedModules = [
                (flake.outPath + ${builtins.toJSON cfg.completion.homeModule})
              ];
            }];
          };
        in extended.options.home-manager.users.type.getSubOptions []
      '';
    };
  };
in {
  imports = [
    (import ./languages/support.nix {
      name = "nix";
      description = "Nix development tools";
      optionPath = ["development" "nix"];
      packages = pkgs: [pkgs.nixfmt-rfc-style pkgs.nixd pkgs.alejandra];
      vscodeExtensions = pkgs: {nix = pkgs.vscode-extensions.jnoortheen.nix-ide;};
      zedExtensions.nix = "nix";
      zedPackages = pkgs: [pkgs.nixd pkgs.alejandra];
      zedSettings.languages.Nix = {
        language_servers = ["nixd" "!nil"];
        format_on_save = "on";
        formatter.external = {
          command = "alejandra";
          arguments = ["-q" "-"];
        };
      };
      neovimServers = ["nixd"];
      neovimGrammars = ["nix"];
      neovimFormatters.nix = ["alejandra"];
    })
  ];

  options.development.nix.completion = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Configure nixd to complete this dotfiles flake's custom module options";
    };
    flakePath = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/source/dotfiles";
      description = "Absolute path to the live dotfiles checkout used by nixd";
    };
    hostName = lib.mkOption {
      type = lib.types.str;
      default =
        args.osConfig.networking.hostName or (
          if pkgs.stdenv.hostPlatform.isDarwin
          then "fearful"
          else "fear"
        );
      description = "Flake host whose system and Home Manager options nixd completes";
    };
    homeModule = lib.mkOption {
      type = lib.types.str;
      default = "/nix/nixos/hosts/${cfg.completion.hostName}/home.nix";
      description = "Home Manager module path relative to the flake, including its per-user imports";
    };
  };

  config = lib.mkIf (config.development.enable && cfg.enable && cfg.completion.enable && editors.enable) (lib.mkMerge [
    (lib.mkIf editors.neovim.enable {
      programs.nixvim.plugins.lsp.servers.nixd.settings = lib.mapAttrsRecursive (_: lib.mkDefault) nixdSettings;
    })
    (lib.mkIf editors.zed.enable {
      programs.zed-editor.userSettings.lsp.nixd = {
        binary.path = lib.mkDefault (lib.getExe pkgs.nixd);
        # The Nix extension wraps this object under the "nixd" namespace.
        settings = lib.mapAttrsRecursive (_: lib.mkDefault) nixdSettings;
      };
    })
  ]);
}
