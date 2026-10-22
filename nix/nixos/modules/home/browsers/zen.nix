{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.browsers.zen;
  extensionPackages = pkgs.nur.repos.rycee.firefox-addons;
  bundledExtensions = {
    ublockOrigin = extensionPackages.ublock-origin;
    darkreader = extensionPackages.darkreader;
    protonpass = extensionPackages.proton-pass;
    karakeep = extensionPackages.karakeep;
  };
  needsProfile =
    builtins.any (extension: cfg.extensions.${extension}) (builtins.attrNames bundledExtensions)
    || cfg.settings.doNotTrack
    || cfg.settings.trackingProtection
    || cfg.settings.disableTelemetry
    || cfg.advanced.extensions != []
    || cfg.advanced.settings != {};
  profilesIni = "${config.programs.zen-browser.configPath}/profiles.ini";
in {
  imports = [inputs.zen-browser.homeModules.beta];

  options.browsers.zen = {
    enable = lib.mkEnableOption "Zen Browser";
    extensions =
      builtins.mapAttrs (
        extension: _:
          lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Install the bundled ${extension} Zen Browser extension";
          }
      )
      bundledExtensions;
    settings = {
      doNotTrack = lib.mkEnableOption "the Do Not Track header";
      trackingProtection = lib.mkEnableOption "tracking protection";
      disableTelemetry = lib.mkEnableOption "disabling telemetry";
    };
    advanced = {
      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Additional Zen Browser extension packages";
      };
      settings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "Additional or overriding Zen Browser profile preferences";
      };
    };
  };

  config = lib.mkIf (config.browsers.enable && cfg.enable) {
    # Gecko otherwise treats each new Nix store path as a separate install and
    # selects a fresh profile, hiding the existing extensions and settings.
    home.sessionVariables.MOZ_LEGACY_PROFILES = "1";
    launchd.agents.zenLegacyProfiles = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      enable = true;
      config = {
        Label = "org.nixos.zenLegacyProfiles";
        ProgramArguments = ["/bin/launchctl" "setenv" "MOZ_LEGACY_PROFILES" "1"];
        RunAtLoad = true;
      };
    };

    programs.zen-browser = {
      enable = true;
      profiles = lib.optionalAttrs needsProfile {
        default = {
          settings =
            lib.recursiveUpdate (
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
            )
            cfg.advanced.settings;
          extensions.packages =
            builtins.attrValues (lib.filterAttrs (extension: _: cfg.extensions.${extension}) bundledExtensions)
            ++ cfg.advanced.extensions;
        };
      };
    };

    # Zen needs to update profiles.ini when it creates its first macOS profile.
    # The Firefox Home Manager module normally links this file to the read-only
    # Nix store, which leaves Zen at the profile chooser on a fresh install.
    home.file."${profilesIni}".enable = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (lib.mkForce false);
    home.activation.zenWritableProfiles = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
      lib.hm.dag.entryAfter ["linkGeneration"] ''
        profiles_ini=${lib.escapeShellArg profilesIni}
        if [ -L "$profiles_ini" ]; then
          case "$(readlink "$profiles_ini")" in
            /nix/store/*) $DRY_RUN_CMD rm "$profiles_ini" ;;
          esac
        fi
        if [ ! -e "$profiles_ini" ] && [ ! -L "$profiles_ini" ]; then
          $DRY_RUN_CMD cp ${lib.escapeShellArg (toString config.home.file."${profilesIni}".source)} "$profiles_ini"
          $DRY_RUN_CMD chmod u+w "$profiles_ini"
        fi
      ''
    );
  };
}
