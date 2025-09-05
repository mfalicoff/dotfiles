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
  cfg = config.homelab.services.paperless;
  service = "paperless";
in
{
  options.homelab.services.paperless = {
    enable = mkEnableOption "Enable paperless";
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
      domain = "https://paperless.caddy.mazilious.org";
      database.createLocally = true;
      consumptionDir = "${config.smb.paths.documents}/paperless/consume";
      mediaDir = "${config.smb.paths.documents}/paperless/media";

      settings = {
        PAPERLESS_CONSUMER_POLLING = 60;
      };
    };
    users.users.paperless.group = "paperless";
    users.groups.paperless = { };
    users.users.paperless.extraGroups = [ "users" ];

    homelab.services.glance.monitorSites = [
      (mkGlanceMonitor {
        service = service;
        icon = "di:${service}-ngx";
      })
    ];

    services.postgresqlBackup.databases = [ "paperless" ];

    services.borgbackup.jobs.${service} = mkBorgJob {
      paths = config.services.${service}.dataDir;
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
