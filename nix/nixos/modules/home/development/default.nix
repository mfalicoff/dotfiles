{ lib, ... }:
{
  imports = [
    ./editors
    ./git.nix
    ./languages
    ./environment.nix
    ./cloud.nix
    ./containers.nix
    ./kubernetes.nix
    ./nix.nix
    ./secrets.nix
    ./tools.nix
    ./desktop.nix
  ];

  options.development.enable = lib.mkEnableOption "development configuration";
}
