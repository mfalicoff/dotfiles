{ config, lib, ... }:
with lib;
let
  cfg = config.homelab.services;
in
{
  imports = [
    ./arr.nix
    ./glance.nix
  ];

  options.homelab.services = {
    enable = mkEnableOption "Enable Homelab services";
  };

  config = mkIf cfg.enable {
    homelab.services = {
      arr.enable = true;
      glance.enable = true;
    };
  };
}
