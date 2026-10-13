import ./support.nix {
  name = "dart";
  description = "Dart development tools";
  packages = pkgs: [pkgs.dart];
  vscodeExtensions = pkgs: {dart = pkgs.vscode-extensions.dart-code.dart-code;};
  zedExtensions.dart = "dart";
  neovimServers = ["dartls"];
  neovimGrammars = ["dart"];
  neovimFormatters = {
    dart = ["dart_format"];
  };
}
