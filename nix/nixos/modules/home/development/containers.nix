{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.development.containers.enable = lib.mkEnableOption "containers development tools";

  config = lib.mkIf (config.development.enable && config.development.containers.enable) {
    home.packages = with pkgs; [
      compose2nix
      lazydocker
    ];
  };
}
