{inputs}: let
  inherit (inputs.nixpkgs) lib;
  mkHome = system: settings: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
    (inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ../nix/nixos/modules/home/ai
        {
          home.username = "test";
          home.homeDirectory =
            if pkgs.stdenv.hostPlatform.isDarwin
            then "/Users/test"
            else "/home/test";
          home.stateVersion = "24.11";
        }
        settings
      ];
    }).config;
  linux = mkHome "x86_64-linux";
  darwin = mkHome "aarch64-darwin";
  empty = linux {};
  parentOnly = linux {ai.enable = true;};
  disabledParent = linux {ai.pi.enable = true;};
  pi = linux {
    ai = {
      enable = true;
      pi.enable = true;
    };
    programs.pi-coding-agent = {
      settings = {
        theme = "dark";
        defaultProvider = "anthropic";
      };
      keybindings = {"tui.editor.cursorUp" = ["up" "ctrl+p"];};
      models.providers.local = {
        baseUrl = "http://localhost:11434/v1";
        api = "openai-completions";
        models = [{id = "local-model";}];
      };
    };
  };
  piOverride = linux {
    ai = {
      enable = true;
      pi.enable = true;
    };
    programs.pi-coding-agent.settings.packages = ["npm:custom-package"];
  };
  claude = linux {
    ai = {
      enable = true;
      claudeCode.enable = true;
    };
  };
  copilot = linux {
    ai = {
      enable = true;
      copilot.enable = true;
    };
  };
  codex = linux {
    ai = {
      enable = true;
      codex.enable = true;
    };
  };
  chatgpt = darwin {
    ai = {
      enable = true;
      chatgpt.enable = true;
    };
  };
  invalidChatgpt = linux {
    ai = {
      enable = true;
      chatgpt.enable = true;
    };
  };
  packages = c: map lib.getName c.home.packages;
  checks = {
    parentDoesNotSelectTools =
      packages parentOnly
      == packages empty
      && !parentOnly.programs.pi-coding-agent.enable
      && !parentOnly.programs.claude-code.enable
      && !parentOnly.programs.github-copilot-cli.enable
      && !parentOnly.programs.codex.enable;
    childrenRequireParent =
      packages disabledParent
      == packages empty
      && !disabledParent.programs.pi-coding-agent.enable;
    piUsesHomeManagerModule =
      pi.programs.pi-coding-agent.enable
      && pi.programs.pi-coding-agent.settings.theme == "dark"
      && pi.programs.pi-coding-agent.settings.packages
      == [
        "npm:pi-web-access"
        "npm:pi-subagents"
        "npm:@juicesharp/rpiv-ask-user-question"
        "npm:openwiki"
      ]
      && builtins.elem "nodejs" (map lib.getName pi.programs.pi-coding-agent.extraPackages)
      && pi.programs.pi-coding-agent.models.providers.local.models == [{id = "local-model";}]
      && pi.home.file ? "/home/test/.pi/agent/settings.json"
      && pi.home.file ? "/home/test/.pi/agent/keybindings.json"
      && pi.home.file ? "/home/test/.pi/agent/models.json"
      && !pi.programs.claude-code.enable
      && !pi.programs.github-copilot-cli.enable;
    piPackagesCanBeOverridden = piOverride.programs.pi-coding-agent.settings.packages == ["npm:custom-package"];
    agentsAreIndependent =
      claude.programs.claude-code.enable
      && !claude.programs.github-copilot-cli.enable
      && !claude.programs.pi-coding-agent.enable
      && copilot.programs.github-copilot-cli.enable
      && !copilot.programs.claude-code.enable
      && !copilot.programs.pi-coding-agent.enable
      && codex.programs.codex.enable
      && !codex.programs.claude-code.enable;
    chatgptIsDarwinOnly =
      builtins.elem "chatgpt" (packages chatgpt)
      && !chatgpt.programs.pi-coding-agent.enable
      && !chatgpt.programs.claude-code.enable
      && !(builtins.tryEval invalidChatgpt.home.packages).success;
  };
in
  lib.mapAttrs (
    name: passed:
      assert lib.assertMsg passed "AI module regression: ${name}"; passed
  )
  checks
