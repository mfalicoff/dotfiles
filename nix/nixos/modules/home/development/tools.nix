{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.development.tools;

  bundledPackages = {
    age = pkgs.age;
    azureCli = pkgs.azure-cli;
    compose2nix = pkgs.compose2nix;
    lazygit = pkgs.lazygit;
    just = pkgs.just;
    gcc = pkgs.gcc;
    k9s = pkgs.k9s;
    killport = pkgs.killport;
    kubectl = pkgs.kubectl;
    lazydocker = pkgs.lazydocker;
    nixfmt = pkgs.nixfmt-rfc-style;
    kubeseal = pkgs.kubeseal;
    jq = pkgs.jq;
    uv = pkgs.uv;
    nixd = pkgs.nixd;
    alejandra = pkgs.alejandra;
    gitkraken = pkgs.gitkraken;
    yaak = pkgs.yaak;
  };
  packageOptions =
    packages:
    builtins.mapAttrs (
      name: _:
      mkOption {
        type = types.bool;
        default = true;
        description = "Install the bundled ${name} tool";
      }
    ) packages;
  selectedPackages = builtins.attrValues (
    lib.filterAttrs (name: _: cfg.packages.${name}) bundledPackages
  );
in
{
  options.development.tools = {
    enable = mkEnableOption "development tools";
    packages = packageOptions bundledPackages // {
      direnv = mkOption {
        type = types.bool;
        default = true;
        description = "Enable direnv and its Zsh integration";
      };
    };
    advanced.extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional development packages outside the curated list";
    };
  };

  config = mkIf (config.development.enable && cfg.enable) {
    home.packages = selectedPackages ++ cfg.advanced.extraPackages;

    programs.direnv = mkIf cfg.packages.direnv {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
