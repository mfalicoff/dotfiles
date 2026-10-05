{
  config,
  lib,
  ...
}:
{
  options.macos.security.enable = lib.mkEnableOption "macOS security configuration";
  config = lib.mkIf (config.macos.enable && config.macos.security.enable) {
    security.pam.services.sudo_local.touchIdAuth = true;
  };
}
