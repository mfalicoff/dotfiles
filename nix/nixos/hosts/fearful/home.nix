{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ../../../darwin/home.nix
    ../../modules/home
  ];
}
