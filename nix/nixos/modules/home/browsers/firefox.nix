{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.browsers.firefox;
  shared = import ./firefox-like.nix { inherit lib pkgs; };
in
{
  options.browsers.firefox = shared.options "Firefox";

  config = lib.mkIf (config.browsers.enable && cfg.enable) {
    home.packages = lib.optional (!shared.needsProfile cfg) pkgs.firefox;
    programs.firefox = lib.mkIf (shared.needsProfile cfg) {
      enable = true;
      package = pkgs.firefox;
      profiles.default = shared.profile cfg;
    };
  };
}
