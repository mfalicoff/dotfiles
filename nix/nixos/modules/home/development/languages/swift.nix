# The Swift toolchain (and sourcekit-lsp) comes from Xcode on macOS.
import ./support.nix {
  name = "swift";
  description = "Swift editor support";
  vscodeExtensions = pkgs: {swift = pkgs.vscode-extensions.sswg.swift-lang;};
  zedExtensions.swift = "swift";
  neovimServers.sourcekit.package = null;
  neovimGrammars = ["swift"];
}
