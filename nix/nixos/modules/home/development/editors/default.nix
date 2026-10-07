{lib, ...}: {
  imports = [
    ./zed.nix
    ./neovim.nix
    ./vscode.nix
  ];
  options.development.editors.enable = lib.mkEnableOption "development editors";
}
