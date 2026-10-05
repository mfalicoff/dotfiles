{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.development.languages.dotnet;
in
{
  options.development.languages.dotnet = {
    enable = mkEnableOption ".NET SDK";
  };

  config = mkIf (config.development.enable && cfg.enable) {
    home.packages = with pkgs; [
      (
        with dotnetCorePackages;
        combinePackages [
          sdk_10_0
        ]
      )
    ];
  };
}
