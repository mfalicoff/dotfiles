{config, lib, pkgs, ... }:

{
  options.modules.hyprland = {
    enable = lib.mkEnableOption "hyprland configuration";
  };

  config = lib.mkIf config.modules.hyprland.enable {

    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = builtins.readFile ./hyprland.conf;

      settings.exec-once = [
        "hyprpanel"
      ];
    };

    services.hyprpaper = {
      enable = true;
      settings = {
        wallpaper = [
          ", /home/mazilious/.config/nixos/hosts/default/wallpapper.jpg"
          ", /home/mazilious/.config/nixos/hosts/default/wallpapper.jpg"
        ];
      };
    };
  };
}
