import ./support.nix {
  name = "php";
  description = "PHP development tools";
  packages = pkgs: [pkgs.php pkgs.phpPackages.composer];
  jetbrains.phpstorm = pkgs: pkgs.jetbrains.phpstorm;
  vscodeExtensions = pkgs: {php = pkgs.vscode-extensions.bmewburn.vscode-intelephense-client;};
  zedExtensions.php = "php";
  neovimServers = ["phpactor"];
  neovimGrammars = ["php"];
  neovimFormatters = {
    php = ["php_cs_fixer"];
  };
}
