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
  cfg = config.homelab.services.radarr;
  service = "radarr";
in
{
  options.homelab.services.radarr = {
    enable = mkEnableOption "Enable radarr";
    port = mkOption {
      type = types.port;
      description = "port to use";
    };
  };

  config = mkIf cfg.enable {
    services.${service} = {
      enable = true;
      settings.server.port = cfg.port;
    };

    users.users.${service}.extraGroups = [ "users" ];

    services.borgbackup.jobs.${service} = mkBorgJob {
      paths = config.services.${service}.dataDir;
      services = service;
    };

    homelab.services.glance.monitorSites = [
      (mkGlanceMonitor { service = service; })
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
