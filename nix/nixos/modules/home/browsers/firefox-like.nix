{ lib, pkgs }:
let
  bundledExtensions = {
    ublockOrigin = pkgs.nur.repos.rycee.firefox-addons.ublock-origin;
    darkreader = pkgs.nur.repos.rycee.firefox-addons.darkreader;
    protonpass = pkgs.nur.repos.rycee.firefox-addons.proton-pass;
    karakeep = pkgs.nur.repos.rycee.firefox-addons.karakeep;
  };
in
{
  options = name: {
    enable = lib.mkEnableOption name;
    extensions = builtins.mapAttrs (
      extension: _:
      lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install the bundled ${extension} ${name} extension";
      }
    ) bundledExtensions;
    settings = {
      doNotTrack = lib.mkEnableOption "the Do Not Track header";
      trackingProtection = lib.mkEnableOption "tracking protection";
      disableTelemetry = lib.mkEnableOption "disabling telemetry";
    };
    advanced = {
      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Additional ${name} extension packages";
      };
      settings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        description = "Additional or overriding ${name} profile preferences";
      };
    };
  };

  needsProfile =
    cfg:
    builtins.any (extension: cfg.extensions.${extension}) (builtins.attrNames bundledExtensions)
    || cfg.settings.doNotTrack
    || cfg.settings.trackingProtection
    || cfg.settings.disableTelemetry
    || cfg.advanced.extensions != [ ]
    || cfg.advanced.settings != { };

  profile = cfg: {
    settings = lib.recursiveUpdate (
      lib.optionalAttrs cfg.settings.doNotTrack {
        "privacy.donottrackheader.enabled" = true;
      }
      // lib.optionalAttrs cfg.settings.trackingProtection {
        "privacy.trackingprotection.enabled" = true;
      }
      // lib.optionalAttrs cfg.settings.disableTelemetry {
        "toolkit.telemetry.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
      }
    ) cfg.advanced.settings;
    extensions.packages =
      builtins.attrValues (lib.filterAttrs (extension: _: cfg.extensions.${extension}) bundledExtensions)
      ++ cfg.advanced.extensions;
  };
}
