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
  cfg = config.homelab.services.tandoor;
  service = "tandoor-recipes";
in
{
  options.homelab.services.tandoor = {
    enable = mkEnableOption "Enable tandoor";
    port = mkOption {
      type = types.port;
      description = "port to use";
    };
  };

  config = mkIf cfg.enable {
    services.${service} = {
      enable = true;
      port = cfg.port;
      address = "0.0.0.0";

      database.createLocally = true;
    };

    users.users.paperless.extraGroups = [ "users" ];

    homelab.services.glance.monitorSites = [
      (mkGlanceMonitor {
        service = service;
        icon = "di:${service}";
      })
    ];

    services.postgresqlBackup.databases = [ "tandoor_recipes" ];

    services.borgbackup.jobs.${service} = mkBorgJob {
      paths = "/var/lib/tandoor-recipes";
      services = service;
    };

    homelab.monitoring.targets = [
      (mkMonitoringTarget { service = service; })
    ];

    services.caddy.virtualHosts = mkCaddyVirtualHost {
      service = service;
      port = cfg.port;
    };
  };

}
