{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.rofi;
in
{
  options.rofi = {
    enable = mkEnableOption "Enable Rofi";
  };

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      terminal = "${pkgs.alacritty}/bin/alacritty";

      extraConfig = {
        modi = "drun,filebrowser";
        font = "Noto Sans CJK JP 12";
        show-icons = true;
        disable-history = true;
        hover-select = true;
        bw = 0;
        display-drun = "Apps";
        display-window = "Window";
        display-combi = "";
        icon-theme = "Fluent-dark";
        terminal = "kitty";
        drun-match-fields = "name";
        drun-display-format = "{name}";
        me-select-entry = "";
        me-accept-entry = "MousePrimary";
        kb-cancel = "Escape,MouseMiddle";
      };
      theme = mkForce ./theme.rafi;
    };

    home.packages = [ pkgs.bemoji ];
  };
}
