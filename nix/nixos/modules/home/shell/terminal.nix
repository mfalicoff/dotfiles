{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.shellOptions.terminal.enable = lib.mkEnableOption "Ghostty terminal";
  config = lib.mkIf (config.shellOptions.enable && config.shellOptions.terminal.enable) {
    programs.ghostty = {
      enable = true;
      package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
      settings = {
        font-size = 15;
        font-family = "JetBrainsMono Nerd Font";
        theme = "Catppuccin Mocha";
        window-padding-x = 10;
        window-padding-y = 10;
        background-opacity = 0.95;
      };
    };
  };
}
