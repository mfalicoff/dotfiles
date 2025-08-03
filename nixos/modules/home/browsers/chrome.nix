{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.browsers.chrome;
in
{
  options.browsers.chrome = {
    enable = mkEnableOption "Enable Chrome";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      google-chrome
    ];
  };
}
