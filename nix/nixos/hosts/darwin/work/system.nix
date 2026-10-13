{username, ...}: {
  imports = [
    ./host-users.nix
    ../../../modules/system/homebrew
    ../../../modules/system/stylix
  ];

  system.stateVersion = 5;
  system.primaryUser = username;

  security.pam.services.sudo_local.touchIdAuth = true;

  nix.gc.automatic = false;

  styling.stylix.enable = true;

  homebred = {
    enable = true;
    cleanup = "zap";
    taps = [
      "anomalyco/tap"
      "azure/kubelogin"
      "barutsrb/tap"
      "derailed/k9s"
      "grishka/grishka"
      "haakofli/viewbus"
      "hashicorp/tap"
      "powershell/tap"
    ];
    brews = [
      "anomalyco/tap/opencode-v2"
      "chezmoi"
      "docker"
      "eza"
      "fd"
      "fzf"
      "gh"
      "go"
      "k9s"
      "kubernetes-cli"
      "lazygit"
      "mas"
      "mole"
      "powershell"
      "rtk"
      "rustup"
      "sesh"
      "television"
      "tmux"
      "tree-sitter-cli"
      "uv"
      "zoxide"
    ];
    casks = [
      "dotnet-sdk"
      "gitkraken"
      "grishka/grishka/neardrop"
      "haakofli/viewbus/viewbus"
      "homebrew-app"
      "jetbrains-toolbox"
      "microsoft-azure-storage-explorer"
      "mongodb-compass"
      "obsidian"
      "omniwm"
      "opencode-desktop"
      "pocket-casts"
      "spotify"
      "terraform-linters/tap/tflint"
      "textream"
      "visual-studio-code"
      "vorssaint"
      "zen"
    ];
  };

  # Aerofi needs a running user service to handle its global launcher hotkey.
  homebrew.brews = [
    {
      name = "frostymur/tap/aerofi";
      start_service = true;
      restart_service = "changed";
    }
  ];
}
