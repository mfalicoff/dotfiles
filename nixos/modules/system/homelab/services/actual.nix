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
  cfg = config.homelab.services.actual;
  service = "actual";
in
{
  options.homelab.services.actual = {
    enable = mkEnableOption "Enable actual";
    port = mkOption {
      type = types.port;
      description = "port to use";
    };
  };

  config = mkIf cfg.enable {
    services.${service} = {
      enable = true;
      settings.port = cfg.port;
    };

    services.borgbackup.jobs.${service} = mkBorgJob {
      paths = "/var/lib/actual";
      services = service;
    };

    homelab.services.glance.monitorSites = [
      (mkGlanceMonitor { service = "${service}-budget"; })
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
