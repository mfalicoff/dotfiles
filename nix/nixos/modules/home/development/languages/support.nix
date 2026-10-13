# Shared wiring for language bundles.
#
# A language file calls this function with a description of the language and
# gets back a Home Manager module. See _template.nix for a starting point.
#
# Convention: anything that refers to packages is a function of `pkgs`;
# plain data (names, IDs, filetypes) is written directly.
#
# Arguments
#   name                Required. Option name: development.languages.<name>.
#   description         Required. Text for the `enable` option.
#   optionPath          Option path of the bundle. Only set it for bundles that
#                       do not live under development.languages (e.g. nix.nix).
#
#   packages            pkgs: [ package ]. Toolchain installed in home.packages.
#   jetbrains           { <ide> = pkgs: package; }. Adds a <name>.<ide>.enable
#                       switch that installs the IDE (off by default).
#
#   vscodeExtensions    pkgs: { <key> = extension; }. Each key becomes a
#                       development.editors.vscode.extensions.<key> toggle.
#   zedExtensions       { <key> = "zed-extension-id"; }. Toggles under
#                       development.editors.zed.extensions.<key>.
#   zedPackages         pkgs: [ package ]. Language servers put on Zed's PATH.
#   zedSettings         pkgs: { ...Zed user settings... }. Applied with mkDefault.
#
#   neovimServers       [ "lspconfig-name" ] or { <lspconfig-name> = { ...nixvim
#                       server options... }; }. Enabled as nixvim LSP servers.
#   neovimGrammars      [ "treesitter-grammar" ]. Added to ensure_installed.
#   neovimFormatters    { <filetype> = [ "conform-formatter" ]; }. Binaries are
#                       resolved from Nix by conform's autoInstall.
#   neovimLinters       { <filetype> = [ "nvim-lint-linter" ]; }. The linter
#                       binary must be in `packages`.
#
# Editor settings are only applied when development.enable, the bundle and the
# editor (development.editors.<editor>.enable) are all enabled, and are set with
# mkDefault so hosts can override them.
{
  name,
  description,
  optionPath ? ["development" "languages" name],
  packages ? _: [],
  jetbrains ? {},
  vscodeExtensions ? _: {},
  zedExtensions ? {},
  zedPackages ? _: [],
  zedSettings ? _: {},
  neovimServers ? [],
  neovimGrammars ? [],
  neovimFormatters ? {},
  neovimLinters ? {},
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = lib.getAttrFromPath optionPath config;
  enabled = config.development.enable && cfg.enable;
  editors = config.development.editors;
  editorEnabled = editor: editors.enable && editors.${editor}.enable;

  vscode = vscodeExtensions pkgs;

  # One bool toggle per extension so a host can opt out of a single one.
  extensionToggles = editor: extensions:
    lib.mapAttrs (extension: _:
      lib.mkOption {
        type = lib.types.bool;
        default = enabled;
        description = "Install the ${name} ${extension} ${editor} extension";
      })
    extensions;

  # Keep only the extensions whose toggle is still on.
  selectedExtensions = toggles: extensions:
    builtins.attrValues (lib.filterAttrs (extension: _: toggles.${extension}) extensions);

  jetbrainsOptions =
    lib.mapAttrs (ide: _: {
      enable = lib.mkEnableOption "JetBrains ${ide} for ${name}";
    })
    jetbrains;

  jetbrainsPackages = lib.concatLists (lib.mapAttrsToList (
      ide: package: lib.optional cfg.${ide}.enable (package pkgs)
    )
    jetbrains);

  toolchainConfig = {
    home.packages = packages pkgs ++ jetbrainsPackages;
  };

  vscodeConfig = {
    programs.vscode.profiles.default.extensions =
      selectedExtensions editors.vscode.extensions vscode;
  };

  zedConfig = {
    programs.zed-editor = {
      extensions = selectedExtensions editors.zed.extensions zedExtensions;
      extraPackages = zedPackages pkgs;
      userSettings = lib.mapAttrsRecursive (_: lib.mkDefault) (zedSettings pkgs);
    };
  };

  neovimServerSettings =
    if builtins.isList neovimServers
    then lib.genAttrs neovimServers (_: {})
    else neovimServers;

  neovimConfig = lib.mkMerge [
    {
      programs.nixvim.plugins = {
        lsp.servers =
          lib.mapAttrs (_: settings: {enable = lib.mkDefault true;} // lib.mapAttrs (_: lib.mkDefault) settings)
          neovimServerSettings;
        treesitter.settings.ensure_installed = neovimGrammars;
        conform-nvim.settings.formatters_by_ft = lib.mapAttrs (_: lib.mkDefault) neovimFormatters;
      };
    }
    (lib.mkIf (neovimLinters != {}) {
      programs.nixvim.plugins.lint = {
        enable = lib.mkDefault true;
        lintersByFt = lib.mapAttrs (_: lib.mkDefault) neovimLinters;
      };
    })
  ];
in {
  options =
    lib.recursiveUpdate
    (lib.setAttrByPath optionPath ({enable = lib.mkEnableOption description;} // jetbrainsOptions))
    {
      development.editors.vscode.extensions = extensionToggles "VS Code" vscode;
      development.editors.zed.extensions = extensionToggles "Zed" zedExtensions;
    };

  config = lib.mkIf enabled (lib.mkMerge [
    toolchainConfig
    (lib.mkIf (editorEnabled "vscode") vscodeConfig)
    (lib.mkIf (editorEnabled "zed") zedConfig)
    (lib.mkIf (editorEnabled "neovim") neovimConfig)
  ]);
}
