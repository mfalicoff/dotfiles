{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.windowManager.omniwm;
in {
  options.windowManager.omniwm = {
    enable = mkEnableOption "Enable Omniwm window manager";
  };

  config = mkIf (config.windowManager.enable && cfg.enable) {
    programs.omniwm = {
      enable = true;
      settings = ./omniwm-settings.toml;
    };
  };
}
