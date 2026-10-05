{
  config,
  lib,
  pkgs,
  ...
}: {
  options.development.mobile.enable = lib.mkEnableOption "mobile development tools";

  config = lib.mkIf (config.development.enable && config.development.mobile.enable) {
    home.packages = with pkgs; [
      android-tools
      flutter
    ];
  };
}
