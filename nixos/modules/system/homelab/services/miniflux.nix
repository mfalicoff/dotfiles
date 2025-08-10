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
      adminCredentialsFile = config.sops.secrets.miniflux-admin-credentials.path;

      config = {
        LISTEN_ADDR = "0.0.0.0:8900";
        BASE_URL = "https://${service}.caddy.mazilious.org";

        # OAuth2/SSO Configuration
        OAUTH2_PROVIDER = "oidc";
        OAUTH2_OIDC_PROVIDER_NAME = "Pocket";
        OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://pocket.local.mazilious.org";
        OAUTH2_REDIRECT_URL = "https://miniflux.caddy.mazilious.org/oauth2/oidc/callback";
        OAUTH2_CLIENT_ID = "2d3afb27-1046-474d-8c08-5217179268c5";
        OAUTH2_CLIENT_SECRET_FILE = config.sops.secrets.miniflux-oauth2.path;
        OAUTH2_USER_CREATION = "1";
      };
    };

    services.postgresqlBackup.databases = [ "miniflux" ];

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
