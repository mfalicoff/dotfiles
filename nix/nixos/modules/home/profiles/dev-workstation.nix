# Shared defaults for development machines. The base suits restricted hosts;
# the workstation profile adds personal tools. Host assignments always win.
{
  config,
  lib,
  ...
}: {
  options.profiles = {
    devBase.enable = lib.mkEnableOption "the shared core development bundle selection";
    devWorkstation.enable = lib.mkEnableOption "the full development workstation bundle selection";
  };

  config = lib.mkMerge [
    (lib.mkIf (config.profiles.devBase.enable || config.profiles.devWorkstation.enable) {
      development = {
        enable = lib.mkDefault true;
        cloud.enable = lib.mkDefault true;
        containers.enable = lib.mkDefault true;
        kubernetes.enable = lib.mkDefault true;
        nix.enable = lib.mkDefault true;
        tools.enable = lib.mkDefault true;
        editors.enable = lib.mkDefault true;
      };
    })
    (lib.mkIf config.profiles.devWorkstation.enable {
      development = {
        git.enable = lib.mkDefault true;
        secrets.enable = lib.mkDefault true;
        environment.enable = lib.mkDefault true;
        languages = {
          c.enable = lib.mkDefault true;
          python.enable = lib.mkDefault true;
        };
        editors.neovim.enable = lib.mkDefault true;
      };
    })
  ];
}
