import ./languages/support.nix {
  name = "nix";
  description = "Nix development tools";
  optionPath = ["development" "nix"];
  packages = pkgs: [pkgs.nixfmt-rfc-style pkgs.nixd pkgs.alejandra];
  vscodeExtensions = pkgs: {nix = pkgs.vscode-extensions.jnoortheen.nix-ide;};
  zedExtensions.nix = "nix";
  zedPackages = pkgs: [pkgs.nixd pkgs.alejandra];
  zedSettings.languages.Nix = {
    language_servers = ["nixd"];
    format_on_save = "on";
    formatter.external = {
      command = "alejandra";
      arguments = ["-q" "-"];
    };
  };
  neovimServers = ["nixd"];
  neovimGrammars = ["nix"];
  neovimFormatters = {
    nix = ["alejandra"];
  };
}
