{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
    ../common-home.nix
    ../../../modules/home
  ];

  programs.zsh.envExtra = ''
    export PATH="$PATH:$HOME/.dotnet/tools"
  '';

  shellOptions = {
    enable = true;
    zsh.enable = true;
    terminal.enable = true;
    navigation = {
      enable = true;
      fd.enable = true;
    };
    monitoring.enable = true;
    tmux.enable = true;
  };

  ai = {
    enable = true;
    copilot.enable = true;
  };

  profiles.devBase.enable = true;

  development = {
    git.enableLfs = false;
    nix.completion = {
      enable = true;
      flakePath = "${config.home.homeDirectory}/dotfiles";
      hostName = "MFALICOFF-MAC";
      homeModule = "/nix/nixos/hosts/darwin/work/home.nix";
    };
    desktop = {
      enable = true;
      gitkraken.enable = false; # Installed as a Homebrew cask
    };
    languages = {
      go.enable = true;
      terraform.enable = true;
    };
    editors.zed.enable = true;
  };
}
