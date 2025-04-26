{username, ...}: {
  # docker
  virtualisation.docker.enable = true;

  # virt manager
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [username];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  users.users."${username}".extraGroups = ["libvirtd"];
}
