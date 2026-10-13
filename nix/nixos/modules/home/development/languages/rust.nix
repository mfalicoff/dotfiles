import ./support.nix {
  name = "rust";
  description = "Rust development tools";
  packages = pkgs: [pkgs.cargo pkgs.rustc pkgs.rustfmt pkgs.clippy pkgs.rust-analyzer];
  vscodeExtensions = pkgs: {rust = pkgs.vscode-extensions.rust-lang.rust-analyzer;};
  # Rust support is built into Zed.
  zedPackages = pkgs: [pkgs.rust-analyzer];
  # The toolchain comes from `packages`, so nixvim must not install its own.
  neovimServers.rust_analyzer = {
    installCargo = false;
    installRustc = false;
  };
  neovimGrammars = ["rust" "toml"];
  neovimFormatters = {
    rust = ["rustfmt"];
  };
}
