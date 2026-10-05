{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.development.kubernetes.enable = lib.mkEnableOption "kubernetes development tools";

  config = lib.mkIf (config.development.enable && config.development.kubernetes.enable) {
    home.packages = with pkgs; [
      k9s
      kubectl
      kubeseal
    ];
  };
}
