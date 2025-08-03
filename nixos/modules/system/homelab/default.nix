{config, lib, ...}: 
with lib; let 
  cfg = config.homelab;
in 
{
  imports = [
    ./backups.nix
    ./monitoring
    ./services
  ];

  options.homelab = {
    enable = mkEnableOption "Enable Homelab";
  };

  config = mkIf cfg.enable {
    homelab.services.enable = mkDefault false;
    homelab.monitoring.enable = mkDefault false;
  };
}
