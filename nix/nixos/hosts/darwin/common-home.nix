{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
  programs.nh.enable = true;

  # Homebrew is outside the Nix profile, including in non-login shells.
  programs.zsh.envExtra = ''
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$('/opt/homebrew/bin/brew' shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$('/usr/local/bin/brew' shellenv)"
    fi
  '';

  xdg.configFile."aerofi/config.toml".source = ./config/aerofi/config.toml;
  xdg.configFile."aerofi/themes/dotfiles.toml".source = ./config/aerofi/theme.toml;

  # Aerofi watches these writable directories even when they are empty.
  home.activation.prepareAerofiDirectories = lib.hm.dag.entryAfter ["linkGeneration"] ''
    run mkdir -p \
      "${config.xdg.configHome}/aerofi/scripts" \
      "${config.home.homeDirectory}/Library/Application Support/aerofi/plugins"
  '';

  # Seed icons from bundle resources when Aerofi's AppKit extraction fails.
  home.activation.cacheAerofiIcons = lib.hm.dag.entryAfter ["linkGeneration"] ''
    run ${lib.getExe pkgs.python3} ${./config/aerofi/cache-icons.py} \
      "${config.xdg.configHome}/aerofi/config.toml"
  '';
}
