import ./support.nix {
  name = "javascript";
  description = "JavaScript and TypeScript development tools";
  packages = pkgs: [pkgs.nodejs pkgs.eslint_d];
  jetbrains.webstorm = pkgs: pkgs.jetbrains.webstorm;
  vscodeExtensions = pkgs: {eslint = pkgs.vscode-extensions.dbaeumer.vscode-eslint;};
  # JavaScript and TypeScript support is built into VS Code and Zed.
  zedPackages = pkgs: [pkgs.typescript-language-server];
  neovimServers = ["ts_ls" "html" "cssls"];
  neovimGrammars = ["javascript" "typescript" "tsx" "html" "css"];
  neovimFormatters = {
    javascript = ["prettier"];
    javascriptreact = ["prettier"];
    typescript = ["prettier"];
    typescriptreact = ["prettier"];
    html = ["prettier"];
    css = ["prettier"];
    scss = ["prettier"];
  };
  neovimLinters = {
    javascript = ["eslint_d"];
    javascriptreact = ["eslint_d"];
    typescript = ["eslint_d"];
    typescriptreact = ["eslint_d"];
  };
}
