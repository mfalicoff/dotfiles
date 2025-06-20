{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.reverseProxy;
  unraid = "100.94.140.88";
  homeassistant = "100.118.232.49";
in {
  options.reverseProxy = {
    enable = mkEnableOption "Enable Caddy";
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = ["github.com/caddy-dns/cloudflare@v0.2.1"];
        hash = "sha256-2D7dnG50CwtCho+U+iHmSj2w14zllQXPjmTHr6lJZ/A=";
      };
      logDir = "/var/log/caddy";
      dataDir = "/var/lib/caddy";

      virtualHosts = {
        "beszel.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${unraid}:8093
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

        "home.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://${homeassistant}:8123
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

        "jellyseer.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:5055
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

        "paperless.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:8000
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "pocket.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:8000
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "prowlarr.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:9696
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "radarr.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:7878
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "sonarr.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:8989
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "recipes.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:3154
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "stashy.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:9999
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "switch.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:8465
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "tandoor.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:8154
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "torrent.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:8080
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "unraid.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88:3001
            tls {
              dns cloudflare {env.CF_API_TOKEN}
            }
          '';
        };

        "uptime.caddy.mazilious.org" = {
          extraConfig = ''
            reverse_proxy http://100.94.140.88
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
