# Evaluate with the repository's locked inputs; see docs/modules/README.md.
{ inputs }:
let
  inherit (inputs.nixpkgs) lib;
  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
    overlays = [ inputs.nur.overlays.default ];
  };
  home =
    settings:
    (inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs; };
      modules = [
        inputs.nixvim.homeModules.nixvim
        ../nix/nixos/modules/home
        {
          home.username = "test";
          home.homeDirectory = "/home/test";
          home.stateVersion = "24.11";
        }
        settings
      ];
    }).config;
  system =
    settings:
    (lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs.username = "test";
      modules = [
        ../nix/nixos/modules/system/gaming
        ../nix/nixos/modules/system/virtualization
        ../nix/nixos/modules/system/password-manager
        ../nix/nixos/modules/system/hyprland
        {
          nixpkgs.config.allowUnfree = true;
          system.stateVersion = "24.11";
        }
        settings
      ];
    }).config;
  packages = c: builtins.sort builtins.lessThan (map lib.getName c.home.packages);
  empty = home { };
  developmentOnly = home { development.enable = true; };
  tools = home {
    development = {
      enable = true;
      tools.enable = true;
    };
  };
  cloud = home {
    development = {
      enable = true;
      cloud.enable = true;
    };
  };
  disabledDevelopment = home {
    development.tools.enable = true;
    development.git.enable = true;
  };
  shellOnly = home { shellOptions.enable = true; };
  tmuxOnly = home {
    shellOptions = {
      enable = true;
      tmux.enable = true;
    };
  };
  terminalOnly = home {
    shellOptions = {
      enable = true;
      terminal.enable = true;
    };
  };
  navigationOnly = home {
    shellOptions = {
      enable = true;
      navigation.enable = true;
    };
  };
  disabledShell = home {
    shellOptions.zsh.enable = true;
    shellOptions.tmux.enable = true;
  };
  disabledEditors = home {
    development.enable = true;
    development.editors.vscode.enable = true;
  };
  disabledBrowsers = home { browsers.firefox.enable = true; };
  disabledWM = home {
    windowManager.wayland = {
      enable = true;
      hyprland.enable = true;
      bar.waybar.enable = true;
    };
  };
  disabledWayland = home {
    windowManager = {
      enable = true;
      wayland.hyprland.enable = true;
    };
  };
  gamingOnly = system { gaming.enable = true; };
  launchersOnly = system {
    gaming = {
      enable = true;
      launchers.enable = true;
    };
  };
  streamingOnly = system {
    gaming = {
      enable = true;
      streaming.enable = true;
    };
  };
  disabledGaming = system { gaming.launchers.enable = true; };
  containersOnly = system {
    virt = {
      enable = true;
      containers.enable = true;
    };
  };
  virtualMachinesOnly = system {
    virt = {
      enable = true;
      virtualMachines.enable = true;
    };
  };
  disabledVirt = system { virt.containers.enable = true; };
  passwordOnly = system {
    passwordManager = {
      enable = true;
      onePassword.enable = true;
    };
  };
  hyprlandOnly = system { wm.hyprland.enable = true; };
  checks = {
    developmentParentDoesNotSelectBundles = packages developmentOnly == packages empty;
    toolsBundleIncludesItsTools = builtins.all (name: builtins.elem name (packages tools)) [
      "jq"
      "just"
      "killport"
    ];
    toolsDoNotSelectCloud = !(builtins.elem "azure-cli" (packages tools));
    cloudIsOneSwitch =
      builtins.elem "azure-cli" (packages cloud) && !(builtins.elem "kubectl" (packages cloud));
    developmentChildrenRequireTheirDomain =
      packages disabledDevelopment == packages empty && !disabledDevelopment.programs.git.enable;
    shellParentDoesNotSelectBundles = packages shellOnly == packages empty;
    tmuxWorksWithoutZsh = tmuxOnly.programs.tmux.enable && !tmuxOnly.programs.zsh.enable;
    terminalWorksWithoutZsh = terminalOnly.programs.ghostty.enable && !terminalOnly.programs.zsh.enable;
    navigationIncludesItsPrograms =
      navigationOnly.programs.eza.enable
      && navigationOnly.programs.yazi.enable
      && navigationOnly.programs.skim.enable;
    shellChildrenRequireTheirDomain =
      !disabledShell.programs.zsh.enable && !disabledShell.programs.tmux.enable;
    editorsRequireTheirArea = !disabledEditors.programs.vscode.enable;
    browsersRequireTheirDomain =
      !disabledBrowsers.programs.firefox.enable && packages disabledBrowsers == packages empty;
    windowManagersRequireTheirDomain =
      !disabledWM.wayland.windowManager.hyprland.enable && !disabledWM.programs.waybar.enable;
    windowManagersRequireWayland = !disabledWayland.wayland.windowManager.hyprland.enable;
    gamingParentDoesNotSelectBundles =
      !gamingOnly.programs.steam.enable
      && !gamingOnly.programs.gamemode.enable
      && !gamingOnly.services.sunshine.enable;
    launchersDoNotEnableStreaming =
      launchersOnly.programs.steam.enable && !launchersOnly.services.sunshine.enable;
    streamingDoesNotEnableLaunchers =
      streamingOnly.services.sunshine.enable && !streamingOnly.programs.steam.enable;
    gamingChildrenRequireTheirDomain = !disabledGaming.programs.steam.enable;
    containersDoNotEnableVirtualMachines =
      containersOnly.virtualisation.podman.enable && !containersOnly.virtualisation.libvirtd.enable;
    virtualMachinesIncludeManager =
      virtualMachinesOnly.virtualisation.libvirtd.enable
      && virtualMachinesOnly.programs.virt-manager.enable
      && !virtualMachinesOnly.virtualisation.podman.enable;
    virtualizationRequiresItsDomain = !disabledVirt.virtualisation.podman.enable;
    passwordAppsDoNotSelectDesktopIntegration =
      passwordOnly.programs._1password.enable
      && passwordOnly.programs._1password-gui.enable
      && !passwordOnly.services.gnome.gnome-keyring.enable;
    hyprlandToolsAreSeparate =
      hyprlandOnly.programs.hyprland.enable
      && !(builtins.elem "hyprshot" (map lib.getName hyprlandOnly.environment.systemPackages));
  };
in
lib.mapAttrs (
  name: passed:
  assert lib.assertMsg passed "Bundle regression: ${name}";
  passed
) checks
