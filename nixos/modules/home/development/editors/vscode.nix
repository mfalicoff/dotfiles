{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.development.editors.vscode;
in {
  options.development.editors.vscode = {
    enable = mkEnableOption "Enable Visual Studio Code";
    extensions = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "VS Code extensions to install";
    };
    userSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "VS Code settings";
    };
  };

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = cfg.extensions;
      profiles.default.userSettings = cfg.userSettings;
    };

    home.packages = with pkgs; [
      windsurf
    ];
  };
}
