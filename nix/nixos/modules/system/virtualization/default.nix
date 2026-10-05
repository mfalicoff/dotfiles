{ lib, ... }:
{
  imports = [
    ./containers.nix
    ./virtual-machines.nix
  ];
  options.virt.enable = lib.mkEnableOption "virtualization";
}
