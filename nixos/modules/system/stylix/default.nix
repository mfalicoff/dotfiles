{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.styling;
in {
  options.styling.stylix = {
    enable = mkEnableOption "Enable Stylix";
  };

  config = mkIf cfg.stylix.enable {
    stylix.enable = true;
    stylix.image = ./wallpaper.jpg;
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";

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

    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.droid-sans-mono
    ];
  };
}
