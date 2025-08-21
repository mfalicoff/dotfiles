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
  cfg = config.homelab.services.jellyseerr;
  service = "jellyseerr";
in
{
  options.homelab.services.jellyseerr = {
    enable = mkEnableOption "Enable jellyseerr";
    port = mkOption {
      type = types.port;
      description = "port to use";
    };
  };

  config = mkIf cfg.enable {
    services.${service} = {
      enable = true;
      port = cfg.port;
    };

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
  };

}
