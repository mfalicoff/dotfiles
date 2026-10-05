{ lib, ... }:
{
  imports = [
    ./hyprland.nix
    ./waybar.nix
  ];
  options.windowManager.wayland.enable = lib.mkEnableOption "windowManager.wayland configuration";
}
