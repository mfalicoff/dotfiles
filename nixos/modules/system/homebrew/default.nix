{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.homebred;
in {
  options.homebred = {
    # Homebrew basic configuration
    enable = mkEnableOption "homebrew";

    # App categories
    taps = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Homebrew taps to add";
    };
    brews = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Homebrew formulae to install";
    };
    casks = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Homebrew casks to install";
    };
    appStoreApps = mkOption {
      type = types.attrsOf types.int;
      default = {};
      description = "Apps to install from the App Store";
    };
  };

  config = mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
    # Configure homebrew with the user's lists
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        upgrade = true;
        cleanup = "zap";
      };
      masApps = cfg.appStoreApps;
      taps = cfg.taps;
      brews = cfg.brews;
      casks = cfg.casks;
    };
  };
}
