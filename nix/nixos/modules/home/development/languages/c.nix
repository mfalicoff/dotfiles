import ./support.nix {
  name = "c";
  description = "C and C++ development tools";
  packages = pkgs: [pkgs.gcc];
  jetbrains.clion = pkgs: pkgs.jetbrains.clion;
  vscodeExtensions = pkgs: {clangd = pkgs.vscode-extensions.llvm-vs-code-extensions.vscode-clangd;};
  # C and C++ support is built into Zed.
  zedPackages = pkgs: [pkgs.clang-tools];
  neovimServers = ["clangd"];
  neovimGrammars = ["c" "cpp"];
  neovimFormatters = {
    c = ["clang_format"];
    cpp = ["clang_format"];
  };
}
