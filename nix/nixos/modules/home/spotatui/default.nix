{
  inputs,
  pkgs,
  ...
}: let
  examples = "${inputs.spotatui}/examples/plugins";
in {
  # This shared Home Manager tree also serves nix-darwin; install here on NixOS only.
  config = {
    home.packages = [
      (inputs.spotatui.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
        # buildRustPackage derives cargoBuildFeatures from buildFeatures before
        # overrideAttrs runs, so the hook only sees the cargo* attributes.
        cargoBuildFeatures = (old.cargoBuildFeatures or []) ++ ["cover-art"];
        cargoCheckFeatures = (old.cargoCheckFeatures or []) ++ ["cover-art"];
      }))
    ];

    xdg.configFile = {
      "spotatui/config.yml".source = ./config.yml;
      "spotatui/plugins/track-notifier.lua".source = "${examples}/track-notifier.lua";
      "spotatui/plugins/track-info-popup.lua".source = "${examples}/track-info-popup.lua";
      "spotatui/plugins/accent-cycler.lua".source = "${examples}/accent-cycler.lua";
      "spotatui/plugins/session-stats" = {
        source = "${examples}/session-stats";
        recursive = true;
      };
    };
  };
}
