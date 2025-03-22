{
  username,
  pkgs,
  ...
}:
#############################################################
#
#  Host & Users configuration
#
#############################################################
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    # isNormalUser = true;
    home = "/Users/${username}";
    # extraGroups = ["networkmanager" "wheel" "docker"];
    shell = pkgs.zsh;
  };

  environment.shells = [
    pkgs.zsh
  ];
  nix.settings.trusted-users = [username];
  programs.zsh.enable = true;
}
