{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.development.languages.c.enable = lib.mkEnableOption "c development tools";
  config = lib.mkIf (config.development.enable && config.development.languages.c.enable) {
    home.packages = with pkgs; [ gcc ];
  };
}
