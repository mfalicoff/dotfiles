{
  config,
  inputs,
  lib,
  pkgs,
  username,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    inputs.sofka.homeManagerModules.default

    ../../../modules/home
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
    packages = with pkgs; [
    ];
  };

  programs.home-manager.enable = true;

  programs.nh = {
    enable = true;
  };

  # Seed icons from bundle resources when Aerofi's AppKit extraction fails.
  home.activation.cacheAerofiIcons = lib.hm.dag.entryAfter ["linkGeneration"] ''
    run ${lib.getExe pkgs.python3} ${../../../../darwin/config/aerofi/cache-icons.py} \
      "${config.xdg.configHome}/aerofi/config.toml"
  '';
  xdg.configFile."aerofi/config.toml".source = ../../../../darwin/config/aerofi/config.toml;
  xdg.configFile."aerofi/themes/dotfiles.toml".source = ../../../../darwin/config/aerofi/theme.toml;

  # Homebrew is installed outside the Nix profile. Restore its shell
  # environment for every Zsh session, including non-login terminal shells,
  # without failing if Brew is absent.
  programs.zsh.envExtra = ''
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$('/opt/homebrew/bin/brew' shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$('/usr/local/bin/brew' shellenv)"
    fi
  '';

  shellOptions = {
    enable = true;
    zsh.enable = true;
    terminal.enable = true;
    navigation.enable = true;
    monitoring.enable = true;
    tmux.enable = true;
  };

  programs.github-copilot-cli.enable = true;

  development = {
    enable = true;
    git = {
      enable = false;
      enableDelta = false;
      enableLfs = false;
    };
    cloud.enable = true;
    containers.enable = false;
    kubernetes.enable = false;
    nix = {
      enable = true;
      completion = {
        enable = true;
        flakePath = "${config.home.homeDirectory}/dotfiles";
        hostName = "MFALICOFF-MAC";
        homeModule = "/nix/nixos/hosts/darwin/work/home.nix";
      };
    };
    secrets.enable = false;
    tools.enable = false;
    environment.enable = false;
    mobile.enable = false;
    languages = {
      c = {
        enable = false;
        clion.enable = false;
      };
      python = {
        enable = false;
        pycharm.enable = false;
      };
      dotnet = {
        enable = false;
        rider.enable = false;
      };
      javascript = {
        enable = false;
        webstorm.enable = false;
      };
      java = {
        enable = false;
        intellij.enable = false;
      };
      go = {
        enable = false;
        goland.enable = false;
      };
      php = {
        enable = false;
        phpstorm.enable = false;
      };
      ruby = {
        enable = false;
        rubymine.enable = false;
      };
      sql = {
        enable = false;
        datagrip.enable = false;
      };
      terraform.enable = true;
      zig.enable = false;
      elixir.enable = false;
    };
    editors = {
      enable = true;
      zed.enable = true;
      neovim.enable = false;
      vscode.enable = false;
    };
  };
}
