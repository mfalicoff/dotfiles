{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.gaming.launchers.enable = lib.mkEnableOption "gaming launchers";
  config = lib.mkIf (config.gaming.enable && config.gaming.launchers.enable) {
    programs.steam.enable = true;
    environment.systemPackages = [ (pkgs.lutris.override { extraPkgs = pkgs: [ ]; }) ];
  };
}
