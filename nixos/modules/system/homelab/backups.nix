{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.homelab.backups;
  mkBorgJob = {
    paths,
    services,
    dbName ? null,
    dbUser ? null,
    dbHost ? "localhost",
  }: {
    paths = paths;
    repo = "${config.smb.paths.documents}/nixos/${services}";
    doInit = true;
    encryption.mode = "none";
    prune.keep = {
      within = "1d"; # Keep all archives from the last day
      daily = 7;
      weekly = 4;
      monthly = -1;  # Keep at least one archive for each month
    };
    exclude = [
      "*/logs/*"
      "*/Backups/*"
      "*/.DS_Store"
    ];
    compression = "auto,zstd";
    startAt = "daily";
  };
in {
  options.homelab.backups = {
    enable = mkEnableOption "Enable actual";
  };
  config = mkIf cfg.enable {
    services.borgmatic.enable = true;

    services.postgresqlBackup = {
      enable = true;
    };

    services.borgbackup.jobs.postgres = mkBorgJob {
      paths = "/var/backup/postgresql";
      services = "postgresql";
    };

    _module.args = {
      mkBorgJob = mkBorgJob;
    };
  };
}
