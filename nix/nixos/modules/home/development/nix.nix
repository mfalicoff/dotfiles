{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.development.nix.enable = lib.mkEnableOption "nix development tools";

  config = lib.mkIf (config.development.enable && config.development.nix.enable) {
    home.packages = with pkgs; [
      nixfmt-rfc-style
      nixd
      alejandra
    ];
  };
}
