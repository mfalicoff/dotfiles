{
  username,
  pkgs,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel" "docker"];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  nix.settings.trusted-users = [username];
}
