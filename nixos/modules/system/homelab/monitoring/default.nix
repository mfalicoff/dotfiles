{ config, lib, ... }:
with lib;
let
  cfg = config.homelab.monitoring;
in
{
  imports = [
    ./grafana.nix
    ./loki.nix
  ];

  options.homelab.monitoring = {
    enable = mkEnableOption "Enable Homelab monitoring";
  };

  config = mkIf cfg.enable {
    homelab.monitoring = {
      grafana.enable = true;
      loki.enable = true;
    };
  };
}
