{
  config,
  lib,
  username,
  pkgs,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    extraGroups =
      [
        "networkmanager"
        "wheel"
      ]
      ++ lib.optional config.virtualisation.docker.enable "docker";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  nix.settings.trusted-users = [username];
}
