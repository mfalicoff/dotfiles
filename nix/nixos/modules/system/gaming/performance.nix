{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.gaming.performance.enable = lib.mkEnableOption "gaming performance";
  config = lib.mkIf (config.gaming.enable && config.gaming.performance.enable) {
    programs.gamemode.enable = true;
  };
}
