{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.development.editors.vscode;
in
{
  options.development.editors.vscode = {
    enable = mkEnableOption "Enable Visual Studio Code";
  };

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      profiles = {
        default = {
          userSettings = { };
          extensions = with pkgs.vscode-extensions; [
            # Languages
            ms-dotnettools.csharp
            jnoortheen.nix-ide
            ziglang.vscode-zig
            yzhang.markdown-all-in-one
            jnoortheen.nix-ide

            # tools
            csharpier.csharpier-vscode
            alefragnani.project-manager
            ms-vscode-remote.remote-ssh
          ];
        };
      };
    };
  };
}
