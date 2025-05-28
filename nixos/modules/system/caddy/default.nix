{
  config,
  lib,
  pkgs,
  ...
}:
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
        hash = "sha256-Gsuo+ripJSgKSYOM9/yl6Kt/6BFCA6BuTDvPdteinAI=";
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

        "books.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:8083
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "code.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:3200
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "daawarich.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:3008
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "glance.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:8280
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "immich.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:2283
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "jellyfin.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:8096
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "karapeep.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:3010
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "torrent.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:8096
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };
      };
    };

    systemd.services.caddy.serviceConfig.EnvironmentFile = ["/home/mazilious/dotfiles/nixos/modules/system/caddy/.env"];
  };
}
