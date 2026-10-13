import ./support.nix {
  name = "lua";
  description = "Lua development tools";
  packages = pkgs: [pkgs.lua-language-server pkgs.stylua];
  vscodeExtensions = pkgs: {lua = pkgs.vscode-extensions.sumneko.lua;};
  zedExtensions.lua = "lua";
  zedPackages = pkgs: [pkgs.lua-language-server];
  neovimServers = ["lua_ls"];
  neovimGrammars = ["lua" "luadoc"];
  neovimFormatters = {
    lua = ["stylua"];
  };
}
