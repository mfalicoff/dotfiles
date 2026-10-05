{ config, lib, ... }:
{
  options.development.environment.enable = lib.mkEnableOption "direnv shell integration";
  config = lib.mkIf (config.development.enable && config.development.environment.enable) {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
