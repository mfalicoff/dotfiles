# Add this to your NixOS configuration.nix or as a separate module

{
  config,
  lib,
  mkCaddyVirtualHost,
  mkMonitoringTarget,
  ...
}:
with lib;
let
  cfg = config.homelab.services.glance;
  service = "glance";
  mkGlanceMonitor =
    {
      service,
      title ? null,
      subdomain ? service,
      domain ? "caddy.mazilious.org",
      path ? null,
      icon ? "di:${service}",
    }:
    {
      title =
        if title != null then
          title
        else
          strings.toUpper (substring 0 1 service) + substring 1 (stringLength service) service;
      url = "https://${subdomain}.${domain}" + (if path != null then "/${path}" else "");
      icon = icon;
    };
in
{
  options.homelab.services.glance = {
    enable = mkEnableOption "Enable glance";
    port = mkOption {
      type = types.port;
      description = "port to use";
    };

    monitorSites = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            title = mkOption { type = types.str; };
            url = mkOption { type = types.str; };
            icon = mkOption { type = types.str; };
          };
        }
      );
      default = [ ];
      description = "Sites to monitor in the dashboard";
    };

    monitorUnraidSites = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            title = mkOption { type = types.str; };
            url = mkOption { type = types.str; };
            icon = mkOption { type = types.str; };
          };
        }
      );
      default = [ ];
      description = "Sites to monitor in the dashboard";
    };
  };

  config = mkIf cfg.enable {
    services.${service} = {
      enable = true;

      settings = {
        server = {
          host = "0.0.0.0";
          port = cfg.port;
        };

        pages = [
          {
            name = "Home";
            columns = [
              {
                size = "small";
                widgets = [
                  {
                    type = "calendar";
                  }

                  {
                    type = "rss";
                    limit = 10;
                    collapse-after = 3;
                    cache = "3h";
                    feeds = [
                      { url = "https://ciechanow.ski/atom.xml"; }
                      {
                        url = "https://www.joshwcomeau.com/rss.xml";
                        title = "Josh Comeau";
                      }
                      { url = "https://samwho.dev/rss.xml"; }
                      { url = "https://awesomekling.github.io/feed.xml"; }
                      {
                        url = "https://ishadeed.com/feed.xml";
                        title = "Ahmad Shadeed";
                      }
                    ];
                  }

                  {
                    type = "twitch-channels";
                    channels = [
                      "theprimeagen"
                      "cohhcarnage"
                      "christitustech"
                      "blurbs"
                      "asmongold"
                      "jembawls"
                    ];
                  }
                ];
              }

              {
                size = "full";
                widgets = [
                  {
                    type = "hacker-news";
                  }

                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Services Nixos";
                    sites = builtins.sort (a: b: a.title < b.title) cfg.monitorSites;
                  }

                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Services Unraid";
                    sites = builtins.sort (a: b: a.title < b.title) cfg.monitorUnraidSites;
                  }

                  {
                    type = "videos";
                    channels = [
                      "UCXuqSBlHAE6Xw-yeJA0Tunw" # LTT
                      "UCR-DXc1voovS8nhAvccRZhg" # Jeff Geerling
                      "UCv6J_jJa8GJqFwQNgNrMuww" # ServeTheHome
                      "UCOk-gHyjcWZNj3Br4oxwh0A" # Techno Tim
                    ];
                  }

                  {
                    type = "reddit";
                    subreddit = "selfhosted";
                  }
                ];
              }

              {
                size = "small";
                widgets = [
                  {
                    type = "weather";
                    location = "Montreal, Canada";
                  }

                  {
                    type = "markets";
                    markets = [
                      {
                        symbol = "SPY";
                        name = "S&P 500";
                      }
                      {
                        symbol = "XEQT.TO";
                        name = "XEQT";
                      }
                      {
                        symbol = "VFV.TO";
                        name = "VFV";
                      }
                      {
                        symbol = "NVDA";
                        name = "NVIDIA";
                      }
                      {
                        symbol = "AAPL";
                        name = "Apple";
                      }
                      {
                        symbol = "MSFT";
                        name = "Microsoft";
                      }
                      {
                        symbol = "GOOGL";
                        name = "Google";
                      }
                      {
                        symbol = "AMD";
                        name = "AMD";
                      }
                      {
                        symbol = "RDDT";
                        name = "Reddit";
                      }
                    ];
                  }
                ];
              }
            ];
          }
        ];
      };
    };

    homelab.monitoring.targets = [
      (mkMonitoringTarget { service = service; })
    ];

    services.caddy.virtualHosts = mkCaddyVirtualHost {
      service = service;
      port = cfg.port;
    };

    _module.args = {
      mkGlanceMonitor = mkGlanceMonitor;
    };
  };
}
