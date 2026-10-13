# Shared defaults for development machines. Hosts opt in with
# `profiles.devWorkstation.enable = true;` and override only what differs.
# Every value uses mkDefault, so a plain assignment in the host always wins.
{
  config,
  lib,
  ...
}: {
  options.profiles.devWorkstation.enable = lib.mkEnableOption "the shared development workstation bundle selection";

  config = lib.mkIf config.profiles.devWorkstation.enable {
    development = {
      enable = lib.mkDefault true;
      git.enable = lib.mkDefault true;
      cloud.enable = lib.mkDefault true;
      containers.enable = lib.mkDefault true;
      kubernetes.enable = lib.mkDefault true;
      nix.enable = lib.mkDefault true;
      secrets.enable = lib.mkDefault true;
      tools.enable = lib.mkDefault true;
      environment.enable = lib.mkDefault true;
      languages = {
        c.enable = lib.mkDefault true;
        python.enable = lib.mkDefault true;
      };
      editors = {
        enable = lib.mkDefault true;
        neovim.enable = lib.mkDefault true;
      };
    };
  };
}
