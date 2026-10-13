{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.development.cloud;
in {
  options.development.cloud = {
    enable = lib.mkEnableOption "cloud development tools";
    aws.enable = lib.mkEnableOption "the AWS CLI";
    gcp.enable = lib.mkEnableOption "the Google Cloud CLI";
  };

  config = lib.mkIf (config.development.enable && cfg.enable) {
    home.packages =
      [pkgs.azure-cli]
      ++ lib.optional cfg.aws.enable pkgs.awscli2
      ++ lib.optional cfg.gcp.enable pkgs.google-cloud-sdk;
  };
}
