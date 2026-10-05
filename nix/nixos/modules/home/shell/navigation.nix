{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.shellOptions.navigation.enable = lib.mkEnableOption "shell search and file navigation tools";
  config = lib.mkIf (config.shellOptions.enable && config.shellOptions.navigation.enable) {
    home.packages = with pkgs; [
      fzf
      ripgrep
    ];
    programs = {
      eza = {
        enable = true;
        git = true;
        icons = "auto";
        enableZshIntegration = true;
      };
      yazi = {
        enable = true;
        enableZshIntegration = true;
        settings.manager = {
          show_hidden = true;
          sort_dir_first = true;
        };
      };
      skim = {
        enable = true;
        enableBashIntegration = true;
      };
      television = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
