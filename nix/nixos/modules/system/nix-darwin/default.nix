{
  config,
  lib,
  username,
  ...
}: {
  imports = [
    ./keyboard.nix
    ./login.nix
    ./desktop.nix
    ./security.nix
  ];
  options.macos.enable = lib.mkEnableOption "macOS preferences";
  config = {
    system.stateVersion = 5;
    system.primaryUser = username;
  };
}
