{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  examples = "${inputs.spotatui}/examples/plugins";
in
{
  # This shared Home Manager tree also serves nix-darwin; install here on NixOS only.
  config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    home.packages = [
      (inputs.spotatui.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
        buildFeatures = (old.buildFeatures or [ ]) ++ [ "cover-art" ];
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
