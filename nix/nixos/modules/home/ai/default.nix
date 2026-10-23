{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.ai;
in {
  options.ai = {
    enable = lib.mkEnableOption "AI applications and coding agents";
    chatgpt.enable = lib.mkEnableOption "the ChatGPT desktop application";
    pi.enable = lib.mkEnableOption "Pi Coding Agent";
    claudeCode.enable = lib.mkEnableOption "Claude Code";
    copilot.enable = lib.mkEnableOption "GitHub Copilot CLI";
    codex.enable = lib.mkEnableOption "Codex CLI";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.chatgpt.enable || pkgs.stdenv.hostPlatform.isDarwin;
        message = "ai.chatgpt.enable requires macOS";
      }
    ];

    home.packages = lib.optional (cfg.chatgpt.enable && pkgs.stdenv.hostPlatform.isDarwin) pkgs.chatgpt;

    programs.pi-coding-agent = lib.mkIf cfg.pi.enable {
      enable = true;
      extraPackages = lib.mkDefault [pkgs.nodejs];
      settings.packages = lib.mkDefault [
        "npm:pi-web-access"
        "npm:pi-subagents"
        "npm:@juicesharp/rpiv-ask-user-question"
        "npm:openwiki"
      ];
    };
    programs.claude-code.enable = lib.mkIf cfg.claudeCode.enable true;
    programs.github-copilot-cli.enable = lib.mkIf cfg.copilot.enable true;
    programs.codex.enable = lib.mkIf cfg.codex.enable true;
  };
}
