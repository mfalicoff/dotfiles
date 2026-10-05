{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.development.cloud.enable = lib.mkEnableOption "cloud development tools";

  config = lib.mkIf (config.development.enable && config.development.cloud.enable) {
    home.packages = with pkgs; [
      azure-cli
    ];
  };
}
