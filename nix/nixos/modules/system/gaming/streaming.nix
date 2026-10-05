{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.gaming.streaming.enable = lib.mkEnableOption "gaming streaming";
  config = lib.mkIf (config.gaming.enable && config.gaming.streaming.enable) {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };
  };
}
