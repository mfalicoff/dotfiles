{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.development.git;
in {
  options.development.git = {
    enable = mkEnableOption "Enable Git configuration";

    userName = mkOption {
      type = types.str;
      default = "Maximiliano Falicoff";
      description = "Git user name";
    };

    userEmail = mkOption {
      type = types.str;
      default = "git@mazilious.org";
      description = "Git user email";
    };

    defaultBranch = mkOption {
      type = types.str;
      default = "main";
      description = "Default branch name for new repositories";
    };

    enableDelta = mkOption {
      type = types.bool;
      default = true;
      description = "Enable delta diff viewer";
    };

    enableDifftastic = mkOption {
      type = types.bool;
      default = false;
      description = "Use difftastic for structural diffs instead of delta";
    };

    enableLfs = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Git LFS support";
    };
  };

  config = mkIf (config.development.enable && cfg.enable) {
    home.packages = [pkgs.lazygit pkgs.gitkraken pkgs.gh pkgs.git-absorb pkgs.pre-commit pkgs.lefthook];

    programs.delta = mkIf cfg.enableDelta {
      enable = true;
      enableGitIntegration = !cfg.enableDifftastic;
      options.features = "side-by-side";
    };

    programs.difftastic = mkIf cfg.enableDifftastic {
      enable = true;
      git.enable = true;
    };

    home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      rm -f ~/.gitconfig
    '';

    programs.git = {
      enable = true;
      lfs.enable = cfg.enableLfs;
      ignores = [".DS_Store" ".direnv" ".idea" "*.swp"];
      settings = {
        user.name = cfg.userName;
        user.email = cfg.userEmail;
        init.defaultBranch = cfg.defaultBranch;
        push.autoSetupRemote = true;
        pull.rebase = true;
        alias = {
          # common aliases
          br = "branch";
          co = "checkout";
          st = "status";
          ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
          ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
          cm = "commit -m";
          ca = "commit -am";
          dc = "diff --cached";
          amend = "commit --amend -m";
          # aliases for submodule
          update = "submodule update --init --recursive";
          foreach = "submodule foreach";
        };
      };
    };
  };
}
