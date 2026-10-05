{
  config,
  lib,
  ...
}:
{
  options.macos.keyboard.enable = lib.mkEnableOption "macOS keyboard configuration";
  config = lib.mkIf (config.macos.enable && config.macos.keyboard.enable) {
    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };
}
