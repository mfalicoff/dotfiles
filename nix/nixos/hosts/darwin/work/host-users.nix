{username, ...}: {
  users.users."${username}".home = "/Users/${username}";
  nix.settings.trusted-users = [username];
}
