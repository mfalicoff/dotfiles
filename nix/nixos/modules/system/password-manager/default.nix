{
  config,
  lib,
  username,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.passwordManager;
in
{
  options.passwordManager = {
    enable = mkEnableOption "password management";
    onePassword.enable = mkEnableOption "1Password CLI and desktop app";
    desktopIntegration.enable = mkEnableOption "desktop authentication agent and keyring integration";
  };

  config = mkIf cfg.enable {
    programs._1password.enable = cfg.onePassword.enable;
    programs._1password-gui = mkIf cfg.onePassword.enable {
      enable = true;
      polkitPolicyOwners = [ "${username}" ];
    };

    systemd.user.services.polkit-gnome-authentication-agent-1 = mkIf cfg.desktopIntegration.enable {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    services.gnome.gnome-keyring.enable = cfg.desktopIntegration.enable;
    security.pam.services.hyprland.enableGnomeKeyring = cfg.desktopIntegration.enable;
  };
}
