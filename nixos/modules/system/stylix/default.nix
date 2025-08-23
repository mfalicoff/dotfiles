{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.styling;
in
{
  options.styling.stylix = {
    enable = mkEnableOption "Enable Stylix";
  };

  config = mkIf cfg.stylix.enable {
    stylix.enable = true;
    stylix.image = ./boy_heron.png;
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/da-one-sea.yaml";
    stylix.opacity = {
      desktop = 0.0;
      terminal = 0.9;
    };

    stylix.cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 20;
    };

    stylix.fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
    };

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
        nerd-fonts.droid-sans-mono
        nerd-fonts.hack
      ];
    };
  };
}
