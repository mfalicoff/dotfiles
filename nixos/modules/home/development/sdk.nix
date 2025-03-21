{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.development.sdk;
in {
  options.development.sdk = {
    enable = mkEnableOption "Enable Sdk's";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (with dotnetCorePackages;
        combinePackages [
          sdk_8_0
          sdk_9_0
        ])
      nodejs_23
    ];
  };
}
