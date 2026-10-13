{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.development.desktop;
in {
  options.development.desktop = {
    enable = lib.mkEnableOption "desktop development tools";
    gitkraken.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install GitKraken (disable where it comes from elsewhere, such as a Homebrew cask)";
    };
    yaak.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install the Yaak API client";
    };
  };

  config = lib.mkIf (config.development.enable && cfg.enable) {
    home.packages =
      lib.optional cfg.gitkraken.enable pkgs.gitkraken
      ++ lib.optional cfg.yaak.enable pkgs.yaak;
  };
}
