{config, lib, mkBorgJob, ...}:
with lib; let
  cfg = config.homelab.services.arr;
in {
  options.homelab.services.arr = {
    enable = mkEnableOption "Enable arr stack";
  };
  
  config = mkIf cfg.enable {
    services.sonarr.enable = true;
    
    services.borgbackup.jobs.arr = mkBorgJob {
      paths = config.services.sonarr.dataDir;
      services = "arr";
    };
    
    homelab.services.glance.monitorSites = [
      {
        title = "Sonarr";
        url = "https://sonarr.caddy.mazilious.org";
        icon = "si:sonarr";
      }
    ];
    
    services.caddy.virtualHosts = {
      "sonarr.caddy.mazilious.org" = {
        extraConfig = ''
          reverse_proxy http://100.104.27.77:${toString config.services.sonarr.settings.server.port}
          tls {
            dns cloudflare {env.CF_API_TOKEN}
          }
        '';
      };
    };
  };
}