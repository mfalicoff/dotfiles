{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.browsers.zen;
  shared = import ./firefox-like.nix { inherit lib pkgs; };
  profilesIni = "${config.programs.zen-browser.configPath}/profiles.ini";
in
{
  imports = [ inputs.zen-browser.homeModules.beta ];

  options.browsers.zen = shared.options "Zen Browser";

  config = lib.mkIf (config.browsers.enable && cfg.enable) {
    programs.zen-browser = {
      enable = true;
      profiles = lib.optionalAttrs (shared.needsProfile cfg) {
        default = shared.profile cfg;
      };
    };
    # // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    #   # The macOS app is already installed by Homebrew.
    #   package = null;
    # };

    # Zen needs to update profiles.ini when it creates its first macOS profile.
    # The Firefox Home Manager module normally links this file to the read-only
    # Nix store, which leaves Zen at the profile chooser on a fresh install.
    home.file."${profilesIni}".enable = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (lib.mkForce false);
    home.activation.zenWritableProfiles = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
      lib.hm.dag.entryAfter [ "linkGeneration" ] ''
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
