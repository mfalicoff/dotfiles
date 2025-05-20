{config, lib, pkgs, ...}:
with lib; let
  cfg = config.reverseProxy;
in {
  options.reverseProxy = {
    enable = mkEnableOption "Enable Caddy";
  };
  
  config = mkIf cfg.enable {

    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = ["github.com/caddy-dns/cloudflare@v0.2.1"];
        hash = "sha256-saKJatiBZ4775IV2C5JLOmZ4BwHKFtRZan94aS5pO90=";
      };
      logDir = "/var/log/caddy";
      dataDir = "/var/lib/caddy";
      
      virtualHosts = {
        "beszel.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:8093
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };
      };
    };

    systemd.services.caddy.serviceConfig.EnvironmentFile = [ "/home/mazilious/dotfiles/nixos/modules/system/caddy/.env" ];
  };
}