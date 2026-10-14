{inputs, ...}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ../../../darwin/home.nix
    ../../../darwin/plist.nix
    ../../modules/home
  ];

  home.sessionVariables.MOZ_LEGACY_PROFILES = "1";
}
