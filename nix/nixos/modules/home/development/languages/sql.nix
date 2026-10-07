import ./support.nix {
  name = "sql";
  description = "SQL editor support";
  jetbrains.datagrip = pkgs: pkgs.jetbrains.datagrip;
  vscodeExtensions = pkgs: {sql = pkgs.vscode-extensions.inferrinizzard.prettier-sql-vscode;};
  zedExtensions.sql = "sql";
  neovimServers = ["sqls"];
  neovimGrammars = ["sql"];
  neovimFormatters = {
    sql = ["sql_formatter"];
  };
}
