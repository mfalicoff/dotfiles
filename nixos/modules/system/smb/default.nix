{
  config,
  lib,
  username,
  ...
}:
with lib;
let
  cfg = config.smb;
in
{
  options.smb = {
    enable = mkEnableOption "Enable SMB";
  };

  config = mkIf cfg.enable {
    fileSystems."/mnt/media" = {
      device = "//192.168.2.41/media";
      fsType = "cifs";
      options = [
        "credentials=/home/${username}/dotfiles/nixos/modules/system/smb/smb-secrets"
        "x-systemd.automount"
        "noauto"
        "uid=1000"
        "gid=100"
        "file_mode=0664"
        "dir_mode=0775"
      ];
    };

    fileSystems."/mnt/appdata" = {
      device = "//192.168.2.41/appdata";
      fsType = "cifs";
      options = [
        "credentials=/home/${username}/dotfiles/nixos/modules/system/smb/smb-secrets"
        "x-systemd.automount"
        "noauto"
        "uid=1000"
        "gid=100"
        "file_mode=0664"
        "dir_mode=0775"
      ];
    };

    fileSystems."/mnt/documents" = {
      device = "//192.168.2.41/documents";
      fsType = "cifs";
      options = [
        "credentials=/home/${username}/dotfiles/nixos/modules/system/smb/smb-secrets"
        "x-systemd.automount"
        "noauto"
        "uid=1000"
        "gid=100"
        "file_mode=0664"
        "dir_mode=0775"
      ];
    };

    fileSystems."/mnt/downloads" = {
      device = "//192.168.2.41/downloads";
      fsType = "cifs";
      options = [
        "credentials=/home/${username}/dotfiles/nixos/modules/system/smb/smb-secrets"
        "x-systemd.automount"
        "noauto"
        "uid=1000"
        "gid=100"
        "file_mode=0664"
        "dir_mode=0775"
      ];
    };

    fileSystems."/mnt/isos" = {
      device = "//192.168.2.41/isos";
      fsType = "cifs";
      options = [
        "credentials=/home/${username}/dotfiles/nixos/modules/system/smb/smb-secrets"
        "x-systemd.automount"
        "noauto"
        "uid=1000"
        "gid=100"
        "file_mode=0664"
        "dir_mode=0775"
      ];
    };
  };
}
