{
  config,
  lib,
  pkgs,
  ...
}: {
  options.development.tools.enable = lib.mkEnableOption "tools development tools";

  config = lib.mkIf (config.development.enable && config.development.tools.enable) {
    home.packages = with pkgs; [
      just
      jq
      killport
      yaak
    ];
  };
}
