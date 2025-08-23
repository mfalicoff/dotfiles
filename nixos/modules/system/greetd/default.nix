{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib;
let
  cfg = config.loginManager;
in
{
  options.loginManager = {
    enable = mkEnableOption "Enable Login Manager";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      greetd.tuigreet
    ];

    services = {
      greetd = {
        enable = true;
        settings = {
          default_session = {
            user = username;
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
          };
        };
      };
    };
  };
}
