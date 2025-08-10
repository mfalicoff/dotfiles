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
  cfg = config.homelab.services.arr;
  arrServices = [
    "sonarr"
    "radarr"
  ];

  # Helper function to generate service-specific config
  mkArrServiceConfig = service: {
    services.${service}.enable = true;

    services.borgbackup.jobs.arr = mkBorgJob {
      paths = config.services.${service}.dataDir;
      services = "arr";
    };

    homelab.services.glance.monitorSites = [
      (mkGlanceMonitor { service = service; })
    ];

    homelab.monitoring.targets = [
      (mkMonitoringTarget { service = service; })
    ];

    services.caddy.virtualHosts = mkCaddyVirtualHost {
      service = service;
      port = config.services.${service}.settings.server.port;
    };

    users.users.${service}.extraGroups = [ "users" ];
  };

  # Generate configs for all services and merge them
  arrConfigs = map mkArrServiceConfig arrServices;
in
{
  options.homelab.services.arr = {
    enable = mkEnableOption "Enable arr stack";
  };

  config = mkIf cfg.enable (mkMerge arrConfigs);
}
