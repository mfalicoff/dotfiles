{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hardware.graphics.nvidia;
in
{
  options.hardware.graphics.nvidia = {
    enable = mkEnableOption "NVIDIA graphics drivers and custom settings";

    driverPackage = mkOption {
      type = types.package;
      default = config.boot.kernelPackages.nvidiaPackages.stable;
      defaultText = literalExpression "config.boot.kernelPackages.nvidiaPackages.stable";
      description = "The NVIDIA driver package to use.";
      example = literalExpression "config.boot.kernelPackages.nvidiaPackages.beta";
    };

    useOpenSource = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to use the open source NVIDIA kernel modules where available.";
    };

    enableModesetting = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable kernel modesetting.";
    };

    enableSettings = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to install the nvidia-settings control panel.";
    };

    prime = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable NVIDIA PRIME for hybrid graphics setups.";
      };

      offload = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable render offload mode for PRIME.";
        };
      };

      sync = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable sync mode for PRIME.";
        };
      };

      intelBusId = mkOption {
        type = types.str;
        default = "";
        example = "PCI:0:2:0";
        description = "Bus ID of the Intel GPU. Only needed for PRIME setups.";
      };

      nvidiaBusId = mkOption {
        type = types.str;
        default = "";
        example = "PCI:1:0:0";
        description = "Bus ID of the NVIDIA GPU. Only needed for PRIME setups.";
      };
    };

    powerManagement = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable power management features.";
      };

      finegrained = mkOption {
        type = types.bool;
        default = false;
        description = "Enable fine-grained power management.";
      };
    };
  };

  config = mkIf cfg.enable {
    hardware.graphics.enable = true;

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable = cfg.enableModesetting;
      open = cfg.useOpenSource;
      nvidiaSettings = cfg.enableSettings;
      package = cfg.driverPackage;

      # Only enable PRIME-related settings if PRIME is enabled
      prime = mkIf cfg.prime.enable {
        offload.enable = cfg.prime.offload.enable;
        sync.enable = cfg.prime.sync.enable;
        intelBusId = cfg.prime.intelBusId;
        nvidiaBusId = cfg.prime.nvidiaBusId;
      };

      # Only enable power management if it's enabled
      powerManagement = mkIf cfg.powerManagement.enable {
        enable = true;
        finegrained = cfg.powerManagement.finegrained;
      };
    };

    # Add any necessary packages
    environment.systemPackages = mkIf cfg.enableSettings [
      # The nvidia-settings package is included in the driver package
      cfg.driverPackage.settings
    ];
  };
}
