{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.browsers;
in {
  imports = [
    ./firefox.nix
    ./chrome.nix
    ./zen.nix
  ];

  options.browsers = {
    enable = mkEnableOption "Enable Browsers";
  };

  config = mkIf cfg.enable {
    browsers.firefox.enable = mkDefault false;
    browsers.chrome.enable = mkDefault false;
    browsers.zen.enable = mkDefault false;
  };
}
