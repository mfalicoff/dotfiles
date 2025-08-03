{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.reverseProxy;
  unraid = "100.94.140.88";
  homeassistant = "100.118.232.49";
in
{
  options.reverseProxy = {
    enable = mkEnableOption "Enable Caddy";
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
        hash = "sha256-S1JN7brvH2KIu7DaDOH1zij3j8hWLLc0HdnUc+L89uU=";
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

        "beszel.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:8093
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "books.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:8083
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "calibre.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:8383
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

        "daawarich.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:3008
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

        "glance.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:8280
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

        "jellyseer.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:5055
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "karakeep.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:3010
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "onlyoffice.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:8981
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "owncloud.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:9200
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "paperless.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:8000
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

        "prowlarr.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:9696
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "radarr.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:7878
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "sonarr.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:8989
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "recipes.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:3154
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "strava.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:8480
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "switch.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:8465
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
            reverse_proxy http://${unraid}:3001
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "uptime.local.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };
      };
    };

    systemd.services.caddy.serviceConfig.EnvironmentFile = [
      "/home/mazilious/dotfiles/nixos/modules/system/caddy/.env"
    ];
  };
}
