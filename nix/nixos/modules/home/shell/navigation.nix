{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.shellOptions.navigation;
in {
  options.shellOptions.navigation = {
    enable = lib.mkEnableOption "shell search and file navigation tools";
    skim.enable = lib.mkEnableOption "Skim, a second fuzzy finder alongside fzf and television";
    fd.enable = lib.mkEnableOption "fd, a faster find";
    dust.enable = lib.mkEnableOption "dust, a visual du";
  };
  config = lib.mkIf (config.shellOptions.enable && cfg.enable) {
    home.packages = with pkgs;
      [
        fzf
        ripgrep
      ]
      ++ lib.optional cfg.fd.enable fd
      ++ lib.optional cfg.dust.enable dust;
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
      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
      bat.enable = true;
      skim = lib.mkIf cfg.skim.enable {
        enable = true;
        enableZshIntegration = true;
      };
      television = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
