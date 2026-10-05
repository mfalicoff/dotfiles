{ inputs }:
let
  inherit (inputs.nixpkgs) lib;
  system =
    platform: settings:
    (lib.nixosSystem {
      system = platform;
      specialArgs = { inherit inputs; };
      modules = [
        ../nix/nixos/modules/system/boot
        { system.stateVersion = "24.11"; }
        settings
      ];
    });
  latest = system "x86_64-linux" { bootManager.enable = true; };
  defaultKernel = system "x86_64-linux" {
    bootManager = {
      enable = true;
      kernel = "default";
    };
  };
  zen = system "x86_64-linux" {
    bootManager = {
      enable = true;
      kernel = "zen";
    };
  };
  cachyos = system "x86_64-linux" {
    bootManager = {
      enable = true;
      kernel = "cachyos";
    };
  };
  disabled = system "x86_64-linux" { bootManager.kernel = "cachyos"; };
  unsupported = system "aarch64-linux" {
    bootManager = {
      enable = true;
      kernel = "cachyos";
    };
  };
  invalid = system "x86_64-linux" {
    bootManager = {
      enable = true;
      kernel = "typo";
    };
  };
  cache = "https://attic.xuyh0120.win/lantian";
  checks = {
    keepsLatestByDefault =
      latest.config.boot.kernelPackages.kernel.drvPath == latest.pkgs.linuxPackages_latest.kernel.drvPath;
    selectsNixpkgsDefault =
      defaultKernel.config.boot.kernelPackages.kernel.drvPath
      == defaultKernel.pkgs.linuxPackages.kernel.drvPath;
    selectsZen =
      zen.config.boot.kernelPackages.kernel.drvPath == zen.pkgs.linuxPackages_zen.kernel.drvPath;
    preservesCachyosProviderDerivation =
      cachyos.config.boot.kernelPackages.kernel.drvPath
      == inputs.nix-cachyos-kernel.legacyPackages.x86_64-linux.linuxPackages-cachyos-latest.kernel.drvPath;
    cachyosAddsItsCache = builtins.elem cache cachyos.config.nix.settings.substituters;
    otherKernelsDoNotAddTheCache = !(builtins.elem cache latest.config.nix.settings.substituters);
    disabledBootDoesNotSelectCachyos =
      disabled.config.boot.kernelPackages.kernel.drvPath == disabled.pkgs.linuxPackages.kernel.drvPath
      && !(builtins.elem cache disabled.config.nix.settings.substituters);
    rejectsUnsupportedCachyosPlatform = builtins.any (
      a: a.message == "bootManager.kernel = cachyos requires x86_64-linux." && !a.assertion
    ) unsupported.config.assertions;
    rejectsUnknownKernel = !(builtins.tryEval invalid.config.bootManager.kernel).success;
  };
in
lib.mapAttrs (
  name: passed:
  assert lib.assertMsg passed "Kernel regression: ${name}";
  passed
) checks
