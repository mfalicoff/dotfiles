{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.browsers.chrome;
in
{
  options.browsers.chrome = {
    enable = lib.mkEnableOption "Google Chrome";
    settings = {
      startMaximized = lib.mkEnableOption "starting Chrome maximized";
      incognito = lib.mkEnableOption "starting Chrome in Incognito mode";
    };
    advanced.commandLineArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional Google Chrome command line arguments";
    };
  };

  config = lib.mkIf (config.browsers.enable && cfg.enable) {
    programs.google-chrome = {
      enable = true;
      package = pkgs.google-chrome;
      commandLineArgs =
        lib.optional cfg.settings.startMaximized "--start-maximized"
        ++ lib.optional cfg.settings.incognito "--incognito"
        ++ cfg.advanced.commandLineArgs;
    };
  };
}
