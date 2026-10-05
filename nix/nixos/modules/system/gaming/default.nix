{ lib, ... }:
{
  imports = [
    ./launchers.nix
    ./emulation.nix
    ./performance.nix
    ./streaming.nix
  ];
  options.gaming.enable = lib.mkEnableOption "gaming";
}
