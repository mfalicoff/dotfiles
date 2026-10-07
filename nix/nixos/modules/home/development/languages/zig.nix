import ./support.nix {
  name = "zig";
  description = "Zig development tools";
  packages = pkgs: [pkgs.zig];
  vscodeExtensions = pkgs: {zig = pkgs.vscode-extensions.ziglang.vscode-zig;};
  zedExtensions.zig = "zig";
  neovimServers = ["zls"];
  neovimGrammars = ["zig"];
  neovimFormatters = {
    zig = ["zigfmt"];
  };
}
