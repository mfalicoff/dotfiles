{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.development;
in {
  imports = [
    ./editors
    ./sdk.nix
    ./tools.nix
  ];

  options.development = {
    enable = mkEnableOption "Enable Developer tools";
  };

  config = mkIf cfg.enable {
    development.editors.enable = true;
    development.sdk.enable = true;
    development.tools.enable = true;
  };
}
