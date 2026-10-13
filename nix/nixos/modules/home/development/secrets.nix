{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.development.secrets;
in {
  options.development.secrets = {
    enable = lib.mkEnableOption "secrets development tools";
    gnupg.enable = lib.mkEnableOption "GnuPG, for signing commits and tags";
  };

  config = lib.mkIf (config.development.enable && cfg.enable) {
    home.packages =
      [pkgs.age pkgs.sops pkgs.ssh-to-age]
      ++ lib.optional cfg.gnupg.enable pkgs.gnupg;
  };
}
