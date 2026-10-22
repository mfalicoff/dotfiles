{lib, ...}: {
  imports = [
    ./zen.nix
    ./chrome.nix
  ];
  options.browsers.enable = lib.mkEnableOption "browsers configuration";
}
