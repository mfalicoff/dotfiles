{
  config,
  lib,
  pkgs,
  useremail,
  ...
}:
with lib; let
  cfg = config.development.tools;
in {
  options.development.tools = {
    enable = mkEnableOption "Enable Tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      azure-cli
      direnv
      gitkraken
      lazygit
      just
      gcc
      k9s
      killport
      kubectl
      lazydocker
      kubeseal
      k9s
      jq
    ];

    home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      rm -f ~/.gitconfig
    '';
    
    programs.git = {
      enable = true;
      lfs.enable = true;

      userEmail = useremail;
      userName = "Maximiliano Falicoff";

      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
      };

      delta = {
        enable = true;
        options = {
          features = "side-by-side";
        };
      };

       aliases = {
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

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
