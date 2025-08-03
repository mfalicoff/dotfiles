{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.browsers.zen;
in {
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  options.browsers.zen = {
    enable = mkEnableOption "Enable Zen";
  };

  config = mkIf cfg.enable {
    programs.zen-browser.enable = true;
  };
}
