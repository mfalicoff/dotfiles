{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.shellOptions;
in {
  imports = [
    ./shell.nix
    ./tmux.nix
  ];

  options.shellOptions = {
    enable = mkEnableOption "Enable Shell";
  };

  config = mkIf cfg.enable {
    shellOptions.shell = {
      enable = true;
      tmux.enable = true;
    };
  };
}
