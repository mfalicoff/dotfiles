{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.browsers.zen;
in {
  options.browsers.zen = {
    enable = mkEnableOption "Enable Zen";
  };

  config = mkIf cfg.enable {
    programs.zen-browser.enable = true;
  };
}
