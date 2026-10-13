import ./support.nix {
  name = "shell";
  description = "Shell scripting tools";
  packages = pkgs: [pkgs.bash-language-server pkgs.shellcheck pkgs.shfmt];
  vscodeExtensions = pkgs: {
    shellcheck = pkgs.vscode-extensions.timonwong.shellcheck;
    shellFormat = pkgs.vscode-extensions.foxundermoon.shell-format;
  };
  # Bash support is built into Zed.
  zedPackages = pkgs: [pkgs.bash-language-server pkgs.shellcheck];
  neovimServers = ["bashls"];
  neovimGrammars = ["bash"];
  neovimFormatters = {
    sh = ["shfmt"];
    bash = ["shfmt"];
  };
}
