{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.browsers.firefox;
in {
  options.browsers.firefox = {
    enable = mkEnableOption "Enable Firefox";
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles = {
        "${username}" = {
          bookmarks = {
            force = true;
            settings = [];
          };
          search.engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = ["@np"];
            };
          };
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            onepassword-password-manager
            darkreader
            vimium
          ];
        };
      };
    };
    stylix.targets.firefox.profileNames = ["mazilious"];
  };
}
