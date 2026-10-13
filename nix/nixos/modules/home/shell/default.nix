{
  config,
  lib,
  ...
}: let
  cfg = config.shellOptions;
  # Prefer the first enabled editor; hosts can override with shellOptions.editor.
  detectedEditor =
    if config.programs.nixvim.enable or false
    then "nvim"
    else if config.programs.zed-editor.enable or false
    then "zeditor --wait"
    else if config.programs.vscode.enable or false
    then "code --wait"
    else null;
  editor =
    if cfg.editor != null
    then cfg.editor
    else detectedEditor;
in {
  imports = [
    ./zsh.nix
    ./terminal.nix
    ./navigation.nix
    ./monitoring.nix
    ./tmux.nix
  ];
  options.shellOptions = {
    enable = lib.mkEnableOption "shell configuration";
    editor = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Command used for EDITOR. Defaults to the enabled development editor (Neovim, Zed, then VS Code); EDITOR is left unset when none is enabled.";
    };
  };
  config = lib.mkIf cfg.enable {
    home.sessionVariables =
      {
        XDG_PICTURES_DIR = "~/screenshots";
      }
      // lib.optionalAttrs (editor != null) {EDITOR = editor;};
  };
}
