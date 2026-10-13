{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.development.containers;
  composeProvider = lib.getExe pkgs.docker-compose;
  dockerCompat = pkgs.writeShellScriptBin "docker" ''
    export PODMAN_COMPOSE_PROVIDER=${composeProvider}
    exec ${lib.getExe pkgs.podman} "$@"
  '';
  composeCompat = pkgs.writeShellScriptBin "docker-compose" ''
    export PODMAN_COMPOSE_PROVIDER=${composeProvider}
    exec ${lib.getExe pkgs.podman} compose "$@"
  '';
in {
  options.development.containers = {
    enable = lib.mkEnableOption "Podman container development tools with Docker command compatibility";
    desktop.enable = lib.mkEnableOption "Podman Desktop";
  };

  config = lib.mkIf (config.development.enable && cfg.enable) {
    home.packages = with pkgs;
      [
        podman
        dockerCompat
        composeCompat
        compose2nix
        lazydocker
        dive
        hadolint
      ]
      ++ lib.optional cfg.desktop.enable podman-desktop;

    # Pin the provider so the docker-compose compatibility command cannot be
    # selected recursively by `podman compose`.
    home.sessionVariables.PODMAN_COMPOSE_PROVIDER = composeProvider;
  };
}
