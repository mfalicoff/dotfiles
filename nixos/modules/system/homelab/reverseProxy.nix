{
  config,
  lib,
  pkgs,
  ...
}:
# todo make a backup
with lib;
let
  cfg = config.homelab.reverseProxy;
  unraid = "100.94.140.88";
  homeassistant = "100.118.232.49";

  mkCaddyVirtualHost =
    {
      service,
      port,
      subdomain ? service,
      domain ? "caddy.mazilious.org",
      targetHost ? "100.104.27.77",
      dnsProvider ? "cloudflare",
      envVar ? "CF_API_TOKEN",
    }:
    {
      "${subdomain}.${domain}" = {
        extraConfig = ''
          reverse_proxy http://${targetHost}:${toString port}
          tls {
            dns ${dnsProvider} {env.${envVar}}
          }
        '';
      };
    };
in
{
  options.homelab.reverseProxy = {
    enable = mkEnableOption "Enable Caddy";
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
        hash = "sha256-AcWko5513hO8I0lvbCLqVbM1eWegAhoM0J0qXoWL/vI=";
      };
      logDir = "/var/log/caddy";
      dataDir = "/var/lib/caddy";

      virtualHosts = {
        "affine.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:3210
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "daawarich.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:3008
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "code.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:3200
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "excalidraw.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:5432
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "home.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${homeassistant}:8123
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "immich.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:2283
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "jellyfin.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:8096
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "pocket.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:3012
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "tandoor.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:8154
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "torrent.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:8080
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "unraid.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };
      };
    };

    systemd.services.caddy.serviceConfig.EnvironmentFile = config.sops.secrets.caddy.path;

    _module.args = {
      mkCaddyVirtualHost = mkCaddyVirtualHost;
    };
  };
}
