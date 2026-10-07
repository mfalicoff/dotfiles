import ./support.nix {
  name = "python";
  description = "Python development tools";
  packages = pkgs: [pkgs.uv];
  jetbrains.pycharm = pkgs: pkgs.jetbrains.pycharm;
  vscodeExtensions = pkgs: {
    python = pkgs.vscode-extensions.ms-python.python;
    pylance = pkgs.vscode-extensions.ms-python.vscode-pylance;
  };
  # Python support is built into Zed.
  zedPackages = pkgs: [pkgs.pyright];
  neovimServers = ["pyright"];
  neovimGrammars = ["python"];
  neovimFormatters = {
    python = ["ruff_format"];
  };
}
