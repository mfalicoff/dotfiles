{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.development.tools;
in
{
  options.development.tools = {
    enable = mkEnableOption "Enable Tools";

    enableCli = mkOption {
      type = types.bool;
      default = true;
      description = "Enable CLI applications";
    };

    enableGui = mkOption {
      type = types.bool;
      default = true;
      description = "Enable GUI applications";
    };

    exclude = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of package names to exclude from installation";
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      let
        cliPackages = [
          age
          azure-cli
          compose2nix
          direnv
          lazygit
          just
          gcc
          k9s
          killport
          kubectl
          lazydocker
          nixfmt-rfc-style
          kubeseal
          jq
          uv
        ];

        guiPackages = [
          gitkraken
          yaak
        ];

        selectedPackages =
          [ ] ++ (optionals cfg.enableCli cliPackages) ++ (optionals cfg.enableGui guiPackages);

        filteredPackages = builtins.filter (
          p: !(builtins.elem (lib.getName p) cfg.exclude)
        ) selectedPackages;
      in
      filteredPackages;

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
