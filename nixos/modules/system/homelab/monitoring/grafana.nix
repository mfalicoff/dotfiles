{
  lib,
  config,
  mkBorgJob,
  pkgs,
  ...
}:
let
  cfg = config.homelab.monitoring.grafana;
  monotoringcfg = config.homelab.monitoring;
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

  options.homelab.monitoring = {
    targets = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          target = lib.mkOption { type = lib.types.str; };
          service = lib.mkOption { type = lib.types.str; };
        };
      });
      default = [];
      description = "List of monitoring targets";
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

          blackbox = {
            enable = true;
            port = 9103;
            configFile = pkgs.writeText "config.yaml"
              ''
                modules:
                  http_2xx:
                    prober: http
                    timeout: 5s
                    http:
                      valid_http_versions:
                        - "HTTP/1.1"
                        - "HTTP/2.0"
                      valid_status_codes: []
                      method: GET
                      follow_redirects: true
                  http_403:
                    prober: http
                    timeout: 5s
                    http:
                      valid_http_versions:
                        - "HTTP/1.1"
                        - "HTTP/2.0"
                      valid_status_codes: [ 403 ]
                      method: GET
                      follow_redirects: true
              '';
          };
        };
        scrapeConfigs = [
          {
            job_name = "worker";
            static_configs = [
              {
                targets = [ "${cfg.hostAddress}:${toString cfg.prometheusNodePort}" ];
              }
            ];
          }
          {
            job_name = "blackbox";
            static_configs = [
              {
                targets = map (t: t.target) monotoringcfg.targets;
                labels = {
                  job = "uptime-monitoring";
                };
              }
            ];
            metrics_path = "/probe";
            params = {
              module = [ "http_2xx" ];
            };
            relabel_configs = [
              {
                source_labels = [ "__address__" ];
                target_label = "__param_target";
              }
              {
                source_labels = [ "__param_target" ];
                target_label = "instance";
              }
              {
                target_label = "__address__";
                replacement = "127.0.0.1:9103";  # blackbox exporter address
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
