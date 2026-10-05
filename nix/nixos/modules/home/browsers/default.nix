{ lib, ... }:
{
  imports = [
    ./firefox.nix
    ./zen.nix
    ./chrome.nix
  ];
  options.browsers.enable = lib.mkEnableOption "browsers configuration";
}
