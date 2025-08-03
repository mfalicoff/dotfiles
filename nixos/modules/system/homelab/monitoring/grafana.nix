{
  lib,
  config,
  mkBorgJob,
  ...
}:
let
  cfg = config.homelab.monitoring.grafana;
in
{
  options.homelab.monitoring.grafana = {
    enable = lib.mkEnableOption "Enable monitoring with Grafana and Prometheus";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "grafana.pve.elmurphy.com";
      description = "Domain for Grafana";
    };
    hostAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "IP address of host";
    };
    grafanaPort = lib.mkOption {
      type = lib.types.port;
      default = 2342;
      description = "Port for Grafana to be advertised on";
    };
    prometheusPort = lib.mkOption {
      type = lib.types.port;
      default = 9001;
      description = "Port for Prometheus to be advertised on";
    };
    prometheusNodePort = lib.mkOption {
      type = lib.types.port;
      default = 9002;
      description = "Port for Prometheus node to be advertised on";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      grafana = {
        enable = true;
        settings = {
          server = {
            domain = cfg.domain;
            http_port = cfg.grafanaPort;
            http_addr = cfg.hostAddress;
          };
        };
      };
      prometheus = {
        enable = true;
        port = cfg.prometheusPort;
        exporters = {
          node = {
            enable = true;
            enabledCollectors = [ "systemd" ];
            port = cfg.prometheusNodePort;
          };
        };
        scrapeConfigs = [
          {
            job_name = "media";
            static_configs = [
              {
                targets = [ "${cfg.hostAddress}:${toString cfg.prometheusNodePort}" ];
              }
            ];
          }
        ];
      };
    };

    services.borgbackup.jobs.grafana = mkBorgJob {
      paths = config.services.grafana.dataDir;
      services = "monitoring/grafana";
    };

    homelab.services.glance.monitorSites = [
      {
        title = "Grafana";
        url = "https://grafana.caddy.mazilious.org";
        icon = "si:grafana";
      }
    ];

    services.caddy.virtualHosts = {
      "grafana.caddy.mazilious.org" = {
        extraConfig = ''
          reverse_proxy http://100.104.27.77:${toString cfg.grafanaPort}
          tls {
            dns cloudflare {env.CF_API_TOKEN}
          }
        '';
      };
    };
  };
}
