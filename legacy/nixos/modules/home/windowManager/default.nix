{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.windowManager;
in
{
  imports = [
    ./aerospace
    ./hyprland
  ];

  options.windowManager = {
    enable = mkEnableOption "Enable Window manager";
  };

  config = mkIf cfg.enable {
    # When development.editors is enabled, make sure at least one of the
    # sub-module activation options is properly propagated

    # Note: Users will still need to explicitly enable specific editors
    # This just ensures the modules themselves are loaded
    windowManager.aerospace.enable = mkDefault false;
    windowManager.wayland.enable = mkDefault false;
  };
}
