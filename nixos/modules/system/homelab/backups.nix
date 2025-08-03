{
  config,
  lib,
  pkgs,
  ...
}:

let
  mkBorgJob =
    {
      paths,
      services,

      dbName ? null,
      dbUser ? null,
      dbHost ? "localhost",
    }:
    {
      paths = paths;
      repo = "/mnt/appdata/nixos/backups/${services}";
      doInit = true;
      encryption.mode = "none";
      exclude = [
        "*/logs/*"
        "*/Backups/*"
        "*/.DS_Store"
      ];
      compression = "auto,zstd";
      startAt = "daily";
    };

in
{
  services.borgmatic.enable = true;
  _module.args.mkBorgJob = mkBorgJob;
}
