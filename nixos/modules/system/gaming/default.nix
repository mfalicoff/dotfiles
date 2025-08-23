{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.gaming;
in {
  options.gaming = {
    enable = mkEnableOption "Enable Gaming";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ryubing
      (lutris.override {
        extraPkgs = pkgs: [];
      })
    ];

    programs.steam.enable = true;
    programs.gamemode.enable = true;

    services.sunshine = {
      enable = true;
      package = pkgs.sunshine.override {cudaSupport = true;};
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };
  };
}
