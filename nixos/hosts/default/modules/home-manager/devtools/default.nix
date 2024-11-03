{ lib, config, pkgs, inputs, ...}:

{
  options.modules.devtools = {
    enable = lib.mkEnableOption "Enable devtools";
  };
  

  config = lib.mkIf config.modules.devtools.enable {
    home.packages = with pkgs; [
      vscode
      jetbrains.rider
      jetbrains.webstorm
      gitkraken
      direnv
    ];

    programs.git = {
      enable = true;
      userEmail = "mfalicoff@yahoo.com";
      userName = "Maximiliano Falicoff";
    };

    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        dracula-theme.theme-dracula
        yzhang.markdown-all-in-one
      ];
    };
  };
}
