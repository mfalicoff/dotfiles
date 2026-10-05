{
  config,
  lib,
  ...
}:
{
  options.macos.login.enable = lib.mkEnableOption "macOS login configuration";
  config = lib.mkIf (config.macos.enable && config.macos.login.enable) {
    programs.nix-plist-manager = {
      enable = true;
      options.applications.systemSettings.lockScreen.loginWindowShows = "Name and password";
    };
  };
}
