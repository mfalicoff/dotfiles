{
  config,
  lib,
  pkgs,
  useremail,
  ...
}:
with lib; let
  cfg = config.development.tools;
in {
  options.development.tools = {
    enable = mkEnableOption "Enable Tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      azure-cli
      direnv
      gitkraken
      just
      gcc
      k9s
      killport
      kubectl
      lazydocker
    ];

    programs.git = {
      enable = true;
      userEmail = useremail;
      userName = "Maximiliano Falicoff";
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
