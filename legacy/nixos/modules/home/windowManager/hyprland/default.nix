{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.windowManager.wayland;
in
{
  imports = [
    ./hyprland.nix
    ./waybar.nix
  ];

  options.windowManager.wayland = {
    enable = mkEnableOption "Enable window manager configuration";
  };

  config = mkIf cfg.enable {
    # Enable both components when custom.hyprland.enable = true
    windowManager.wayland.hyprland.enable = mkDefault false;
    windowManager.wayland.bar.waybar.enable = mkDefault false;
  };
}
