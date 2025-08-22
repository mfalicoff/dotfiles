{
  config,
  lib,
  mkGlanceMonitor,
  ...
}:
with lib;
let
  cfg = config.homelab.services;
in
{
  imports = [
    ./actual.nix
    ./byparr.nix
    ./glance.nix
    ./jellyseerr.nix
    ./karakeep.nix
    ./miniflux.nix
    ./ownfoil.nix
    ./paperless.nix
    ./prowlarr.nix
    ./radarr.nix
    ./sonarr.nix
    ./strava.nix
    ./tandoor.nix
  ];

  options.homelab.services = {
    enable = mkEnableOption "Enable Homelab services";
  };

  config = mkIf cfg.enable {
    homelab.services = {
      actual = {
        enable = true;
        port = 9000;
      };
      byparr = {
        enable = true;
        port = 8191;
      };
      glance = {
        enable = true;
        port = 5678;
      };
      jellyseerr = {
        enable = true;
        port = 5055;
      };
      karakeep = {
        enable = true;
        port = 8901;
      };
      miniflux = {
        enable = true;
        port = 8900;
      };
      ownfoil = {
        enable = true;
        port = 8465;
      };
      paperless = {
        enable = true;
        port = 8070;
      };
      prowlarr = {
        enable = true;
        port = 8991;
      };
      radarr = {
        enable = true;
        port = 7878;
      };
      sonarr = {
        enable = true;
        port = 8989;
      };
      strava-statistics = {
        enable = true;
        port = 8480;
      };
      tandoor = {
        enable = true;
        port = 8560;
      };

      glance.monitorUnraidSites = [
        (mkGlanceMonitor {
          service = "torrent";
          icon = "di:qbittorrent";
          domain = "local.mazilious.org";
        })
        (mkGlanceMonitor {
          service = "pocket";
          icon = "di:pocket-id";
          domain = "local.mazilious.org";
        })
        (mkGlanceMonitor {
          service = "jellyfin";
          icon = "di:jellyfin";
          domain = "local.mazilious.org";
        })
        (mkGlanceMonitor {
          service = "immich";
          icon = "di:immich";
          domain = "local.mazilious.org";
        })
        (mkGlanceMonitor {
          service = "navidrome";
          icon = "di:navidrome";
          domain = "local.mazilious.org";
        })
        (mkGlanceMonitor {
          service = "affine";
          icon = "di:affine";
          domain = "local.mazilious.org";
        })
        (mkGlanceMonitor {
          service = "owncloud";
          icon = "di:owncloud";
          domain = "local.mazilious.org";
        })
        (mkGlanceMonitor {
          service = "paperless";
          icon = "di:paperless";
          domain = "local.mazilious.org";
        })
        (mkGlanceMonitor {
          service = "tandoor";
          icon = "di:tandoor-recipes";
          domain = "local.mazilious.org";
        })
        (mkGlanceMonitor {
          service = "unraid";
          icon = "di:unraid";
          domain = "local.mazilious.org";
        })
      ];
    };
  };
}
