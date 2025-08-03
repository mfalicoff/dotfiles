# Add this to your NixOS configuration.nix or as a separate module

{ config, lib, ... }:
with lib;
let
  cfg = config.homelab.services.glance;
in
{
  options.homelab.services.glance = {
    enable = mkEnableOption "Enable glance";

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
  };

  config = mkIf cfg.enable {
    services.glance = {
      enable = true;

      settings = {
        server = {
          host = "0.0.0.0";
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
                    title = "Services";
                    sites = builtins.sort (a: b: a.title < b.title) cfg.monitorSites;
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
      {
        target = "https://glance.caddy.mazilious.org";
        service = "glance";
      }
    ];

    services.caddy.virtualHosts = {
      "glance.caddy.mazilious.org" = {
        extraConfig = ''
          reverse_proxy http://100.104.27.77:${toString config.services.glance.settings.server.port}
          tls {
            dns cloudflare {env.CF_API_TOKEN}
          }
        '';
      };
    };
  };
}
