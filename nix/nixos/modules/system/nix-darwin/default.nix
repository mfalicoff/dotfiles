{
  config,
  lib,
  pkgs,
  username,
  ...
}:
{
  imports = [
    ./keyboard.nix
    ./login.nix
    ./desktop.nix
    ./security.nix
  ];
  options.macos.enable = lib.mkEnableOption "macOS preferences";
  config = {
    # nix-darwin indexes these apps under /Applications/Nix Apps.
    environment.systemPackages = [ pkgs.vscode ];
    system.stateVersion = 5;
    system.primaryUser = username;
  };
}
