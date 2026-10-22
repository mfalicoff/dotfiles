{
  pkgs,
  lib,
  ...
}: {
  nix.settings =
    {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://zed.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
      ];
    }
    // lib.optionalAttrs (lib.versionAtLeast pkgs.nix.version "2.24") {
      download-buffer-size = 268435456;
    };

  nixpkgs.config.allowUnfree = true;

  nix.package = pkgs.nix;

  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # The scheduled optimiser avoids the concurrent-build failure that
  # auto-optimise-store triggers (https://github.com/NixOS/nix/issues/7273).
  nix.optimise.automatic = lib.mkDefault true;
}
