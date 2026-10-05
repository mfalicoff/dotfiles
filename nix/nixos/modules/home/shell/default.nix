{ config, lib, ... }:
{
  imports = [
    ./zsh.nix
    ./terminal.nix
    ./navigation.nix
    ./monitoring.nix
    ./tmux.nix
  ];
  options.shellOptions.enable = lib.mkEnableOption "shell configuration";
  config = lib.mkIf config.shellOptions.enable {
    home.sessionVariables = {
      EDITOR = "nvim";
      XDG_PICTURES_DIR = "~/screenshots";
    };
  };
}
