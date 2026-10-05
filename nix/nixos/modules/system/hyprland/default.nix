{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.wm.hyprland;
in
{
  options.wm.hyprland = {
    enable = mkEnableOption "Hyprland";
    tools.enable = mkEnableOption "Wayland clipboard, locking, screenshot, and display tools";
    portals.enable = mkEnableOption "desktop portal integration";
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      optionals cfg.tools.enable [
        wl-clipboard
        swayidle
        swaylock
        hyprshot
        wlr-randr
        clipse
      ];

    xdg.portal = mkIf cfg.portals.enable {
      enable = true;
      wlr.enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };
}
