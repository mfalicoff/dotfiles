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
    ./git.nix
    ./sdk.nix
    ./tools.nix
  ];

  options.development = {
    enable = mkEnableOption "Enable Developer tools";
  };

  config = mkIf cfg.enable {
    development.editors.enable = mkDefault false;
    development.sdk.enable = mkDefault false;
    development.tools.enable = mkDefault true;
    development.git.enable = mkDefault true;
  };
}
