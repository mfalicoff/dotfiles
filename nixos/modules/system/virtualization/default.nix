{config, lib, username, ...}: 
with lib; let
  cfg = config.virt;
in {
  options.virt = {
    enable = mkEnableOption "Enable Virtualisation";
  };

  config = mkIf cfg.enable {
    # docker
    virtualisation.docker.enable = true;

    # virt manager
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = [username];
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;

    users.users."${username}".extraGroups = ["libvirtd"];
  };
}
