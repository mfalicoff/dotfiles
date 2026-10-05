{ config, lib, ... }:
{
  options.virt.containers.enable = lib.mkEnableOption "Podman containers with Docker compatibility and network DNS";
  config = lib.mkIf (config.virt.enable && config.virt.containers.enable) {
    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];
    virtualisation.oci-containers.backend = "podman";
  };
}
