{ lib, config, pkgs, inputs, ...}:

{
  options = {
    hyprland.enable = lib.mkEnableOption "Enable hyprland";
  };
  
  config = lib.mkIf config.hyprland.enable {
    environment.systemPackages = with pkgs; [
      wl-clipboard
      swayidle
      hyprpaper
      swaylock
      wlogout
      hyprpanel
      rofi-wayland
    ];

    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      xwayland.enable = true;
    };
  };
}
