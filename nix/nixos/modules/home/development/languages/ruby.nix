import ./support.nix {
  name = "ruby";
  description = "Ruby development tools";
  packages = pkgs: [pkgs.ruby];
  jetbrains.rubymine = pkgs: pkgs.jetbrains.ruby-mine;
  vscodeExtensions = pkgs: {ruby = pkgs.vscode-extensions.shopify.ruby-lsp;};
  zedExtensions.ruby = "ruby";
  neovimServers = ["ruby_lsp"];
  neovimGrammars = ["ruby"];
  neovimFormatters = {
    ruby = ["rubocop"];
  };
}
