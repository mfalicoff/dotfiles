{
  config,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.sshServer;
in {
  options.sshServer = {
    enable = mkEnableOption "Enable ssh server";
    authorizedKeyFiles = mkOption {
      type = types.listOf types.path;
      default = [./authorized_keys];
      description = "Files of public keys allowed to log in as the primary user";
    };
    fail2ban.enable = mkEnableOption "fail2ban to ban hosts with repeated failed logins";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [22];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
        MaxAuthTries = 3;
      };
    };
    services.fail2ban.enable = cfg.fail2ban.enable;
    users.users."${username}".openssh.authorizedKeys.keyFiles = cfg.authorizedKeyFiles;
  };
}
