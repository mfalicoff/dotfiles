import ./support.nix {
  name = "elixir";
  description = "Elixir development tools";
  packages = pkgs: [pkgs.elixir];
  vscodeExtensions = pkgs: {elixir = pkgs.vscode-extensions.elixir-lsp.vscode-elixir-ls;};
  zedExtensions.elixir = "elixir";
  zedSettings = {
    lsp.elixir-ls.settings.dialyzerEnabled = true;
    languages = builtins.listToAttrs (map (name: {
      inherit name;
      value = {
        language_servers = ["!lexical" "elixir-ls" "!next-ls"];
        format_on_save = "on";
        formatter.external = {
          command = "mix";
          arguments = ["format" "--stdin-filename" "{buffer_path}" "-"];
        };
      };
    }) ["Elixir" "HEEx"]);
  };
  neovimServers = ["elixirls"];
  neovimGrammars = ["elixir" "heex"];
  neovimFormatters = {
    elixir = ["mix"];
    heex = ["mix"];
  };
}
