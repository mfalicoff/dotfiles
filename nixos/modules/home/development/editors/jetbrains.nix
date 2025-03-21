{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.development.editors.jetbrains;
in {
  options.development.editors.jetbrains = {
    enable = mkEnableOption "Enable JetBrains IDEs";
    rider = mkEnableOption "Enable JetBrains Rider";
    webstorm = mkEnableOption "Enable JetBrains WebStorm";
    intellij = mkEnableOption "Enable JetBrains IntelliJ IDEA";
    pycharm = mkEnableOption "Enable JetBrains PyCharm";
    clion = mkEnableOption "Enable JetBrains CLion";
    phpstorm = mkEnableOption "Enable JetBrains PhpStorm";
    rubymine = mkEnableOption "Enable JetBrains RubyMine";
    datagrip = mkEnableOption "Enable JetBrains DataGrip";
    goland = mkEnableOption "Enable JetBrains GoLand";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs.jetbrains;
      (optional cfg.rider rider)
      ++ (optional cfg.webstorm webstorm)
      ++ (optional cfg.intellij idea-ultimate)
      ++ (optional cfg.pycharm pycharm-professional)
      ++ (optional cfg.clion clion)
      ++ (optional cfg.phpstorm phpstorm)
      ++ (optional cfg.rubymine rubymine)
      ++ (optional cfg.datagrip datagrip)
      ++ (optional cfg.goland goland);
  };
}
