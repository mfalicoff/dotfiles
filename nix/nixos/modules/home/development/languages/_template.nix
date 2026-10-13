# Template for a new language bundle (not imported anywhere).
#
# To add a language:
#   1. Copy this file to <name>.nix and delete the fields you do not need.
#   2. Add ./<name>.nix to the imports in default.nix.
#   3. Add the name to `languageNames` in tests/development.nix.
#   4. Add a row to the language table in docs/modules/home.md.
#
# Every field except `name` and `description` is optional. See support.nix for
# the full reference. Anything that refers to packages is a function of `pkgs`.
import ./support.nix {
  # Becomes development.languages.example.enable.
  name = "example";
  description = "Example development tools";

  # Toolchain installed with the bundle.
  packages = pkgs: [pkgs.hello];

  # Optional IDE switches: development.languages.example.<ide>.enable.
  jetbrains.idea = pkgs: pkgs.jetbrains.idea;

  # VS Code extensions. Find them under pkgs.vscode-extensions.<publisher>.<name>.
  vscodeExtensions = pkgs: {example = pkgs.vscode-extensions.example.example;};

  # Zed extension IDs. Omit when Zed supports the language out of the box and
  # list only the language server in zedPackages instead.
  zedExtensions.example = "example";
  zedPackages = pkgs: [pkgs.hello];
  # Optional Zed user settings (language servers, formatters, ...).
  zedSettings = _: {
    languages.Example = {
      format_on_save = "on";
    };
  };

  # Names come from nvim-lspconfig, nvim-treesitter and conform.nvim.
  # A list, or an attrset of nixvim server options when one needs tweaking.
  neovimServers = ["example_ls"];
  neovimGrammars = ["example"];
  neovimFormatters = {
    example = ["example_fmt"];
  };
  # Linters run through nvim-lint; put their binaries in `packages`.
  neovimLinters = {
    example = ["example_lint"];
  };
}
