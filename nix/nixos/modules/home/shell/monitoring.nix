{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.shellOptions.monitoring.enable = lib.mkEnableOption "terminal system information and monitoring";
  config = lib.mkIf (config.shellOptions.enable && config.shellOptions.monitoring.enable) {
    home.packages = with pkgs; [
      fastfetch
      btop
    ];
  };
}
