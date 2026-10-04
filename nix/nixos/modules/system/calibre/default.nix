{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.calibre;
in
{
  options.calibre = {
    enable = mkEnableOption "Calibre";
  };

  config = mkIf cfg.enable {
    services.udisks2.enable = true;
    services.gvfs.enable = true;
    users.users.mazilious.extraGroups = [ "plugdev" ];
    services.udev.extraRules = ''
      # MTP devices
      SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4ee1", MODE="0664", GROUP="plugdev", TAG+="uaccess"
      # Generic MTP rule
      SUBSYSTEM=="usb", ENV{ID_MTP_DEVICE}=="1", MODE="0664", GROUP="plugdev", TAG+="uaccess"
    '';
    environment.systemPackages = with pkgs; [
      calibre
      libmtp
      gvfs
    ];
  };
}
