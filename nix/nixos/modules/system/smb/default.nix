{
  config,
  lib,
  username,
  ...
}:
with lib;
let
  cfg = config.smb;

  mountSmbShare =
    {
      remote,
      mountPoint,
    }:
    {
      device = remote;
      fsType = "cifs";
      options = [
        "credentials=${config.sops.secrets.smb.path}"
        "x-systemd.automount"
        "noauto"
        "uid=1000"
        "gid=100"
        "file_mode=0664"
        "dir_mode=0775"
      ];
    };

  fileSystems = mapAttrs' (name: share: {
    name = share.mountPoint;
    value = mountSmbShare {
      remote = share.remote;
      mountPoint = share.mountPoint;
    };
  }) cfg.shares;

in
{
  options.smb = {
    enable = mkEnableOption "Enable SMB";

    server = mkOption {
      type = types.str;
      default = "192.168.2.41";
      description = "SMB server IP address";
    };

    shares = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            remote = mkOption {
              type = types.str;
              description = "Remote SMB share path";
            };
            mountPoint = mkOption {
              type = types.str;
              description = "Local mount point";
            };
          };
        }
      );
      default = {
        appdata = {
          remote = "//${cfg.server}/appdata";
          mountPoint = "/mnt/appdata";
        };
        backups = {
          remote = "//${cfg.server}/backups";
          mountPoint = "/mnt/backups";
        };
        documents = {
          remote = "//${cfg.server}/documents";
          mountPoint = "/mnt/documents";
        };
        downloads = {
          remote = "//${cfg.server}/downloads";
          mountPoint = "/mnt/downloads";
        };
        media = {
          remote = "//${cfg.server}/media";
          mountPoint = "/mnt/media";
        };
        isos = {
          remote = "//${cfg.server}/isos";
          mountPoint = "/mnt/isos";
        };
      };
      description = "SMB shares to mount";
    };

    paths = mkOption {
      type = types.attrsOf types.str;
      readOnly = true;
      default = mapAttrs (name: share: share.mountPoint) cfg.shares;
      description = "Paths to mounted SMB shares";
    };
  };

  config = mkIf cfg.enable {
    fileSystems = fileSystems;
  };
}
