{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.shellOptions.monitoring;
in {
  options.shellOptions.monitoring = {
    enable = lib.mkEnableOption "terminal system information and monitoring";
    duf.enable = lib.mkEnableOption "duf, a friendlier df";
    procs.enable = lib.mkEnableOption "procs, a modern ps";
  };
  config = lib.mkIf (config.shellOptions.enable && cfg.enable) {
    home.packages = with pkgs;
      [
        fastfetch
        btop
      ]
      ++ lib.optional cfg.duf.enable duf
      ++ lib.optional cfg.procs.enable procs;
  };
}
