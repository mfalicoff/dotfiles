{lib, ...}: {
  imports = [
    ./omniwm
    ./hyprland
  ];
  options.windowManager.enable = lib.mkEnableOption "windowManager configuration";
}
