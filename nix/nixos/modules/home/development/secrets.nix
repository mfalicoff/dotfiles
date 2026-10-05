{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.development.secrets.enable = lib.mkEnableOption "secrets development tools";

  config = lib.mkIf (config.development.enable && config.development.secrets.enable) {
    home.packages = with pkgs; [
      age
    ];
  };
}
