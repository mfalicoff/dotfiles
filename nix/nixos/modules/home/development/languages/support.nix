# Shared wiring; each language module supplies its own tools and integrations.
{
  name,
  description,
  optionPath ? ["development" "languages" name],
  packages ? _: [],
  jetbrains ? {},
  vscodeExtensions ? _: {},
  zedExtensions ? {},
  zedPackages ? _: [],
  zedSettings ? {},
  neovimServers ? [],
  neovimGrammars ? [],
  neovimFormatters ? {},
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = lib.getAttrFromPath optionPath config;
  enabled = config.development.enable && cfg.enable;
  editors = config.development.editors;
  vscode = vscodeExtensions pkgs;
  extensionOptions = editor: extensions:
    lib.mapAttrs (extension: _:
      lib.mkOption {
        type = lib.types.bool;
        default = enabled;
        description = "Install the ${name} ${extension} ${editor} extension";
      })
    extensions;
in {
  options =
    lib.recursiveUpdate
    (lib.setAttrByPath optionPath ({
        enable = lib.mkEnableOption description;
      }
      // lib.mapAttrs (ide: _: {
        enable = lib.mkEnableOption "JetBrains ${ide} for ${name}";
      })
      jetbrains))
    {
      development.editors.vscode.extensions = extensionOptions "VS Code" vscode;
      development.editors.zed.extensions = extensionOptions "Zed" zedExtensions;
    };

  config = lib.mkIf enabled (lib.mkMerge [
    {
      home.packages =
        packages pkgs
        ++ lib.concatLists (lib.mapAttrsToList (
            ide: package:
              lib.optional cfg.${ide}.enable (package pkgs)
          )
          jetbrains);
    }
    (lib.mkIf (editors.enable && editors.vscode.enable) {
      programs.vscode.profiles.default.extensions =
        builtins.attrValues
        (lib.filterAttrs (extension: _: editors.vscode.extensions.${extension}) vscode);
    })
    (lib.mkIf (editors.enable && editors.zed.enable) {
      programs.zed-editor = {
        extensions =
          builtins.attrValues
          (lib.filterAttrs (extension: _: editors.zed.extensions.${extension}) zedExtensions);
        extraPackages = zedPackages pkgs;
        userSettings = lib.mapAttrsRecursive (_: lib.mkDefault) zedSettings;
      };
    })
    (lib.mkIf (editors.enable && editors.neovim.enable) {
      programs.nixvim.plugins = {
        lsp.servers = lib.genAttrs neovimServers (_: {enable = lib.mkDefault true;});
        treesitter.settings.ensure_installed = neovimGrammars;
        conform-nvim.settings.formatters_by_ft = lib.mapAttrs (_: lib.mkDefault) neovimFormatters;
      };
    })
  ]);
}
