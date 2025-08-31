{
  lib,
  pkgs,
  config,
  mkBorgJob,
  mkGlanceMonitor,
  mkMonitoringTarget,
  mkCaddyVirtualHost,
  ...
}:

let
  cfg = config.homelab.services.strava-statistics;
in
{
  options.homelab.services.strava-statistics = {
    enable = lib.mkEnableOption "Strava statistics service";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8480;
      description = "Port to expose the Strava statistics web service.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.strava = {
      isSystemUser = true;
      uid = 988;
      group = "strava";
      home = "/var/lib/strava";
      createHome = true;
      homeMode = "755";
    };

    users.groups.strava.gid = 984;

    systemd.tmpfiles.rules = [
      "d /var/lib/strava 0755 strava strava -"
      "d /var/lib/strava/build 0755 strava strava -"
      "d /var/lib/strava/config 0755 strava strava -"
      "d /var/lib/strava/storage 0755 strava strava -"
      "d /var/lib/strava/storage/database 0755 strava strava -"
      "d /var/lib/strava/storage/files 0755 strava strava -"
    ];

    virtualisation.oci-containers.containers."statistics-for-strava" = {
      image = "robiningelbrecht/strava-statistics:v3.2.7";
      environmentFiles = [ config.sops.secrets.strava.path ];
      volumes = [
        "/var/lib/strava/build:/var/www/build"
        "/var/lib/strava/config:/var/www/config/app"
        "/var/lib/strava/storage/database:/var/www/storage/database"
        "/var/lib/strava/storage/files:/var/www/storage/files"
      ];
      environment = {
        PUID = "991";
        PGID = "991";
      };
      ports = [ "${toString cfg.port}:8080/tcp" ];
      log-driver = "journald";
      extraOptions = [
        "--network-alias=app"
        "--network=strava-statistics_default"
      ];
    };

    systemd.services."podman-statistics-for-strava".serviceConfig.Restart = lib.mkOverride 90 "always";

    systemd.services."podman-statistics-for-strava".after = [
      "podman-network-strava-statistics_default.service"
    ];

    systemd.services."podman-statistics-for-strava".requires = [
      "podman-network-strava-statistics_default.service"
    ];

    systemd.services."podman-statistics-for-strava".partOf = [
      "podman-compose-strava-statistics-root.target"
    ];

    systemd.services."podman-statistics-for-strava".wantedBy = [
      "podman-compose-strava-statistics-root.target"
    ];

    systemd.services."podman-network-strava-statistics_default" = {
      path = [ pkgs.podman ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "podman network rm -f strava-statistics_default";
      };
      script = ''
        podman network inspect strava-statistics_default || podman network create strava-statistics_default
      '';
      partOf = [ "podman-compose-strava-statistics-root.target" ];
      wantedBy = [ "podman-compose-strava-statistics-root.target" ];
    };

    systemd.targets."podman-compose-strava-statistics-root" = {
      unitConfig.Description = "Root target for Strava statistics (compose2nix)";
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services."statistics-for-strava-update" = {
      path = [ pkgs.podman ];
      serviceConfig.Type = "oneshot";
      script = ''
        echo "Starting Strava data import..."
        podman exec statistics-for-strava bin/console app:strava:import-data

        echo "Starting Strava data build..."
        podman exec statistics-for-strava bin/console app:strava:build-files

        echo "Strava data update completed"
      '';
      after = [ "podman-statistics-for-strava.service" ];
      requires = [ "podman-statistics-for-strava.service" ];
    };

    systemd.timers."statistics-for-strava-update" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "01:00";
        Persistent = true;
      };
    };

    homelab.services.glance.monitorSites = [
      (mkGlanceMonitor {
        service = "strava";
        path = "dashboard";
      })
    ];

    homelab.monitoring.targets = [
      (mkMonitoringTarget { service = "strava"; })
    ];

    services.caddy.virtualHosts = mkCaddyVirtualHost {
      service = "strava";
      port = cfg.port;
    };

    services.borgbackup.jobs.strava = mkBorgJob {
      paths = "/var/lib/strava";
      services = "strava";
    };
  };
}
