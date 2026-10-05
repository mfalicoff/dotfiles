{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.development.desktop.enable = lib.mkEnableOption "desktop development tools";

  config = lib.mkIf (config.development.enable && config.development.desktop.enable) {
    home.packages = with pkgs; [
      gitkraken
      yaak
    ];
  };
}
