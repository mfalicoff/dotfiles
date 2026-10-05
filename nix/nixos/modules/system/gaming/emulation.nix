{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.gaming.emulation.enable = lib.mkEnableOption "gaming emulation";
  config = lib.mkIf (config.gaming.enable && config.gaming.emulation.enable) {
    environment.systemPackages = with pkgs; [
      ryubing
      pcsx2
    ];
  };
}
