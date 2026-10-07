import ./support.nix {
  name = "java";
  description = "Java development tools";
  packages = pkgs: [pkgs.jdk];
  jetbrains.intellij = pkgs: pkgs.jetbrains.idea;
  vscodeExtensions = pkgs: {java = pkgs.vscode-extensions.redhat.java;};
  zedExtensions.java = "java";
  neovimServers = ["jdtls"];
  neovimGrammars = ["java"];
  neovimFormatters = {
    java = ["google-java-format"];
  };
}
