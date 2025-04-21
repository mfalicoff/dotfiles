{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.windowManager.hyprland;
in {
  imports = [
    ./hyprland.nix
    ./hyprpanel.nix
    ./waybar.nix
  ];

  options.windowManager.hyprland = {
    enable = mkEnableOption "Enable Hyprland with HyprPanel or Waybar";
  };

  config = mkIf cfg.enable {
    # Enable both components when custom.hyprland.enable = true
    wm.hyprland.configuration.enable = true;
    # wm.hyprland.panel.enable = true;
    wm.hyprland.waybar.enable = true;
  };
}
