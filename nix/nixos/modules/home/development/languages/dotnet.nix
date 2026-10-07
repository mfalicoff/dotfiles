import ./support.nix {
  name = "dotnet";
  description = ".NET development tools";
  packages = pkgs: [(pkgs.dotnetCorePackages.combinePackages [pkgs.dotnetCorePackages.sdk_10_0])];
  jetbrains.rider = pkgs: pkgs.jetbrains.rider;
  vscodeExtensions = pkgs: {
    csharp = pkgs.vscode-extensions.ms-dotnettools.csharp;
    csharpier = pkgs.vscode-extensions.csharpier.csharpier-vscode;
  };
  zedExtensions.csharp = "csharp";
  neovimServers = ["csharp_ls"];
  neovimGrammars = ["c_sharp"];
  neovimFormatters = {
    cs = ["csharpier"];
  };
}
