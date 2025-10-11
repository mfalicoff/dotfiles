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
  cfg = config.homelab.services.karakeep;
  service = "karakeep";
in
{
  options.homelab.services.karakeep = {
    enable = mkEnableOption "Enable Karakeep";
    port = mkOption {
      type = types.port;
      description = "port to use";
    };
  };

  config = mkIf cfg.enable {
    services.${service} = {
      enable = true;

      extraEnvironment = {
        PORT = toString cfg.port;
        NEXTAUTH_URL = "https://karakeep.caddy.mazilious.org";
        OAUTH_ALLOW_DANGEROUS_EMAIL_ACCOUNT_LINKING = "true";
      };

      environmentFile = config.sops.secrets.karakeep-oauth2.path;
    };

    services.meilisearch.package = pkgs.meilisearch;
    services.meilisearch.enable = mkDefault false;

    homelab.services.glance.monitorSites = [
      (mkGlanceMonitor {
        service = service;
        icon = "di:${service}";
      })
    ];

    homelab.monitoring.targets = [
      (mkMonitoringTarget { service = service; })
    ];

    services.caddy.virtualHosts = mkCaddyVirtualHost {
      service = service;
      port = cfg.port;
    };

    services.borgbackup.jobs.${service} = mkBorgJob {
      paths = "/var/lib/${service}";
      services = service;
    };
  };

}
