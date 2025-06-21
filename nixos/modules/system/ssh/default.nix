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
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [22];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
    users.users."${username}".openssh.authorizedKeys.keyFiles = [
      ./authorized_keys
    ];
  };
}
