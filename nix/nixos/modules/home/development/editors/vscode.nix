{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.development.editors.vscode;
  bundledExtensions = {
    csharp = pkgs.vscode-extensions.ms-dotnettools.csharp;
    nix = pkgs.vscode-extensions.jnoortheen.nix-ide;
    zig = pkgs.vscode-extensions.ziglang.vscode-zig;
    markdown = pkgs.vscode-extensions.yzhang.markdown-all-in-one;
    csharpier = pkgs.vscode-extensions.csharpier.csharpier-vscode;
    projectManager = pkgs.vscode-extensions.alefragnani.project-manager;
    remoteSsh = pkgs.vscode-extensions.ms-vscode-remote.remote-ssh;
  };
in
{
  options.development.editors.vscode = {
    enable = lib.mkEnableOption "Visual Studio Code";
    extensions = builtins.mapAttrs (
      name: _:
      lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install the bundled ${name} VS Code extension";
      }
    ) bundledExtensions;
    settings = {
      formatOnSave = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Format files when saving";
      };
      minimap = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show the editor minimap";
      };
    };
    advanced = {
      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Additional VS Code extension packages";
      };
      settings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        description = "Additional or overriding VS Code user settings";
      };
    };
  };

  config = lib.mkIf (config.development.enable && config.development.editors.enable && cfg.enable) {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      profiles = {
        default = {
          userSettings = lib.recursiveUpdate {
            "editor.formatOnSave" = cfg.settings.formatOnSave;
            "editor.minimap.enabled" = cfg.settings.minimap;
          } cfg.advanced.settings;
          extensions =
            builtins.attrValues (lib.filterAttrs (name: _: cfg.extensions.${name}) bundledExtensions)
            ++ cfg.advanced.extensions;
        };
      };
    };
  };
}
