{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.development.editors;
in
{
  imports = [
    ./zed.nix
    ./neovim.nix
    ./vscode.nix
    ./jetbrains.nix
  ];

  options.development.editors = {
    enable = mkEnableOption "Enable Editors";
  };

  config = mkIf cfg.enable {
    # When development.editors is enabled, make sure at least one of the
    # sub-module activation options is properly propagated

    # Note: Users will still need to explicitly enable specific editors
    # This just ensures the modules themselves are loaded
    development.editors.zed.enable = mkDefault false;
    development.editors.neovim.enable = mkDefault false;
    development.editors.vscode.enable = mkDefault false;
    development.editors.jetbrains.enable = mkDefault false;
  };
}
