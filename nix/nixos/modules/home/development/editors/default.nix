{ lib, ... }:
{
  imports = [
    ./zed.nix
    ./neovim.nix
    ./vscode.nix
    ./jetbrains.nix
  ];
  options.development.editors.enable = lib.mkEnableOption "development editors";
}
