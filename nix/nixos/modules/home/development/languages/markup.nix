import ./support.nix {
  name = "markup";
  description = "YAML, TOML, JSON and Dockerfile support";
  packages = pkgs: [
    pkgs.yaml-language-server
    pkgs.taplo
    pkgs.dockerfile-language-server-nodejs
    pkgs.hadolint
  ];
  vscodeExtensions = pkgs: {
    yaml = pkgs.vscode-extensions.redhat.vscode-yaml;
    toml = pkgs.vscode-extensions.tamasfe.even-better-toml;
    docker = pkgs.vscode-extensions.ms-azuretools.vscode-docker;
  };
  # YAML and JSON support is built into Zed; TOML comes from the editor bundle.
  zedExtensions.dockerfile = "dockerfile";
  zedPackages = pkgs: [pkgs.yaml-language-server pkgs.dockerfile-language-server-nodejs];
  neovimServers = ["yamlls" "jsonls" "taplo" "dockerls"];
  neovimGrammars = ["yaml" "toml" "json" "dockerfile"];
  neovimFormatters = {
    toml = ["taplo"];
  };
  neovimLinters = {
    dockerfile = ["hadolint"];
  };
}
