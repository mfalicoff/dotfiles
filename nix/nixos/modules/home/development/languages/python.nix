{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.development.languages.python.enable = lib.mkEnableOption "python development tools";
  config = lib.mkIf (config.development.enable && config.development.languages.python.enable) {
    home.packages = with pkgs; [ uv ];
  };
}
