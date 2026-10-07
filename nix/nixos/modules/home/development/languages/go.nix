import ./support.nix {
  name = "go";
  description = "Go development tools";
  packages = pkgs: [pkgs.go];
  jetbrains.goland = pkgs: pkgs.jetbrains.goland;
  vscodeExtensions = pkgs: {go = pkgs.vscode-extensions.golang.go;};
  # Go support is built into Zed.
  zedPackages = pkgs: [pkgs.gopls];
  neovimServers = ["gopls"];
  neovimGrammars = ["go" "gomod" "gosum"];
  neovimFormatters = {
    go = ["goimports" "gofmt"];
  };
}
