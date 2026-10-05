{
  config,
  lib,
  username,
  ...
}:
{
  options.virt.virtualMachines.enable = lib.mkEnableOption "libvirt, virt-manager, and SPICE USB redirection";
  config = lib.mkIf (config.virt.enable && config.virt.virtualMachines.enable) {
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = [ username ];
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
    users.users.${username}.extraGroups = [ "libvirtd" ];
  };
}
