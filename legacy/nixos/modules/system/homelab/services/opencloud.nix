{
  config,
  lib,
  mkBorgJob,
  mkGlanceMonitor,
  mkMonitoringTarget,
  mkCaddyVirtualHost,
  ...
}:
with lib;
let
  cfg = config.homelab.services.opencloud;
  service = "opencloud";
in
{
  options.homelab.services.opencloud = {
    enable = mkEnableOption "Enable opencloud";
    port = mkOption {
      type = types.port;
      description = "port to use";
    };
  };

  config = mkIf cfg.enable {
    services.${service} = {
      enable = true;
      port = cfg.port;
      address = "100.104.27.77";
      environment = {
        INSECURE = "true";
        LOG_DRIVER = "local";
        LOG_PRETTY = "true";
        PROXY_TLS = "false";
        OC_INSECURE = "true";
        OC_LOG_LEVEL = "info";
        OC_DOMAIN = "https://opencloud.caddy.mazilious.org";
        OC_URL = "https://opencloud.caddy.mazilious.org";
      };
    };

    services.borgbackup.jobs.${service} = mkBorgJob {
      paths = config.services.${service}.stateDir;
      services = service;
    };

    homelab.services.glance.monitorSites = [
      (mkGlanceMonitor {
        service = service;
        icon = "si:owncloud";
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
