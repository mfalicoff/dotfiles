{
  config,
  lib,
  pkgs,
  mkBorgJob,
  mkGlanceMonitor,
  mkMonitoringTarget,
  mkCaddyVirtualHost,
  ...
}:
with lib;
let
  cfg = config.homelab.services.miniflux;
  service = "miniflux";
in
{
  options.homelab.services.miniflux = {
    enable = mkEnableOption "Enable Miniflux";
    port = mkOption {
      type = types.port;
      description = "port to use";
    };
  };

  config = mkIf cfg.enable {
    services.${service} = {
      enable = true;
      adminCredentialsFile = config.sops.secrets.miniflux.path;

      config = {
        LISTEN_ADDR = "0.0.0.0:8900";
        BASE_URL = "https://${service}.caddy.mazilious.org";
      };
    };

    services.postgresqlBackup.databases = [ "miniflux" ];

    homelab.services.glance.monitorSites = [
      (mkGlanceMonitor {
        service = service;
        icon = "di:${service}-light";
      })
    ];

    homelab.monitoring.targets = [
      (mkMonitoringTarget { service = service; })
    ];

    services.caddy.virtualHosts = mkCaddyVirtualHost {
      service = service;
      port = cfg.port;
    };
  };

}
