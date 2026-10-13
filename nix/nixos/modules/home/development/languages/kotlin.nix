import ./support.nix {
  name = "kotlin";
  description = "Kotlin development tools";
  packages = pkgs: [pkgs.kotlin pkgs.kotlin-language-server];
  vscodeExtensions = pkgs: {kotlin = pkgs.vscode-extensions.mathiasfrohlich.kotlin;};
  zedExtensions.kotlin = "kotlin";
  neovimServers = ["kotlin_language_server"];
  neovimGrammars = ["kotlin"];
}
