{pkgs, ...}: {
  # Bootloader.
  boot = {
    tmp.cleanOnBoot = true;
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
      timeout = null; # Display bootloader indefinitely until user selects OS
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        gfxmodeEfi = "3440x1440";
        gfxmodeBios = "3440x1440";
      };
    };
  };
}
