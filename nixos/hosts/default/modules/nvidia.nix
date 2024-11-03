{ lib, config, pkgs, ...}:
{

  options = {
    nvidia.enable = lib.mkEnableOption "enable nvidia module";
  };

  config = lib.mkIf config.main-user.enable {
    hardware = {
        graphics.enable = true;
    };
    hardware.nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };
}