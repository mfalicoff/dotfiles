{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.bootManager;
  kernels = {
    default = pkgs.linuxPackages;
    latest = pkgs.linuxPackages_latest;
    zen = pkgs.linuxPackages_zen;
    cachyos = inputs.nix-cachyos-kernel.legacyPackages.x86_64-linux.linuxPackages-cachyos-latest;
  };
in
{
  options.bootManager = {
    enable = mkEnableOption "Enable Boot Manager";
    kernel = mkOption {
      type = types.enum (builtins.attrNames kernels);
      default = "latest";
      example = "cachyos";
      description = "Kernel family: Nixpkgs default, latest, Zen, or the pinned CachyOS release";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.kernel != "cachyos" || pkgs.stdenv.hostPlatform.system == "x86_64-linux";
        message = "bootManager.kernel = cachyos requires x86_64-linux.";
      }
    ];

    nix.settings = mkIf (cfg.kernel == "cachyos") {
      substituters = [ "https://attic.xuyh0120.win/lantian" ];
      trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
    };

    # Bootloader.
    boot = {
      tmp.cleanOnBoot = true;
      kernelPackages = kernels.${cfg.kernel};
      loader = {
        efi.canTouchEfiVariables = true;
        efi.efiSysMountPoint = "/boot";
        timeout = 30;
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
  };
}
