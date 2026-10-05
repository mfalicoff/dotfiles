# Home Manager bundles

The shared modules live in [`nix/nixos/modules/home`](../../nix/nixos/modules/home). Hosts select bundles in `home.nix`; macOS selects them in [`nix/darwin/home.nix`](../../nix/darwin/home.nix).

A bundle owns its package list and sensible program settings. Enabling it selects the entire bundle. Adding a tool to an existing bundle takes one edit in that module; hosts already using the bundle receive it automatically. Host-specific extra packages can still go in `home.packages`, and native Home Manager options remain available for exceptional overrides.

Parent switches gate their children. Enabling `development`, `shellOptions`, `browsers`, or `windowManager` does not select their child bundles automatically.

## Development

```nix
{
  development = {
    enable = true;
    git.enable = true;
    tools.enable = true;
    cloud.enable = true;
    containers.enable = true;
    kubernetes.enable = true;
    nix.enable = true;
    secrets.enable = true;
    environment.enable = true;
    desktop.enable = false;
    languages = {
      c.enable = true;
      python.enable = true;
      dotnet.enable = false;
    };
    editors = {
      enable = true;
      neovim.enable = true;
    };
  };
}
```

| Bundle under `development` | Contents |
| --- | --- |
| `git` | Git configuration, lazygit; existing Delta and LFS defaults |
| `tools` | Just, jq, killport |
| `cloud` | Azure CLI |
| `containers` | compose2nix, lazydocker |
| `kubernetes` | kubectl, k9s, kubeseal |
| `nix` | nixfmt, nixd, Alejandra |
| `secrets` | age |
| `environment` | direnv with Zsh integration |
| `desktop` | GitKraken, Yaak; omit on headless hosts |
| `languages.c` | GCC |
| `languages.python` | uv |
| `languages.dotnet` | .NET 10 SDK |
| `editors` | Select Zed, Neovim, VS Code, or JetBrains separately |

Each area lives in its own file under [`development`](../../nix/nixos/modules/home/development). Language bundles live in `development/languages`. The old `development.sdk.enable` is now `development.languages.dotnet.enable`; the old mixed `development.tools` package selection is replaced by the bundles above.

Editors keep their existing presets. For example, `editors.vscode.enable = true` includes its curated extensions, and `editors.neovim.enable = true` includes its plugins and language servers. You do not need to list them in every host. Existing Zed and VS Code `extensions`, `settings`, and `advanced` options remain available for exceptions. JetBrains still uses `jetbrains.enable` plus IDE choices such as `rider = true`.

## Shell

```nix
{
  shellOptions = {
    enable = true;
    zsh.enable = true;
    terminal.enable = true;
    navigation.enable = true;
    monitoring.enable = true;
    tmux.enable = true;
  };
}
```

| Bundle under `shellOptions` | Contents |
| --- | --- |
| `zsh` | Zsh, completion, autosuggestions, highlighting, Pure prompt, Oh My Zsh plugins |
| `terminal` | Ghostty and its existing appearance settings |
| `navigation` | fzf, ripgrep, eza, Yazi, Skim |
| `monitoring` | fastfetch, btop |
| `tmux` | tmux, tmuxinator, curated plugins and key bindings |

These replace the former `shellOptions.shell` bundle. tmux, navigation, and the terminal can be selected independently of Zsh. tmux auto-attaches only when the Zsh bundle is also enabled.

Zsh exposes `extraPlugins`, `shellAliases`, and `initContent` for host-specific additions. The existing tmux options move from `shellOptions.shell.tmux` to `shellOptions.tmux`, including `plugins.weather`, `tmuxinator`, and `advanced.extraConfig`.

## Browsers and window managers

Browsers already form separate bundles: enable `browsers.enable` and then `firefox.enable`, `zen.enable`, or `chrome.enable`. Firefox and Zen keep their curated extensions enabled by default. Their `extensions`, `settings`, and `advanced` options remain available; Chrome retains `settings` and `advanced.commandLineArgs`.

Zen uses the pinned [Zen Browser flake](https://github.com/0xc000022070/zen-browser-flake). On macOS, Home Manager makes `profiles.ini` writable for profile setup. Stylix profile targeting remains a host setting.

Window managers require `windowManager.enable`. Wayland components additionally require `windowManager.wayland.enable`; then select `hyprland.enable` and/or `bar.waybar.enable`. AeroSpace uses `windowManager.aerospace.enable`. Existing monitor, startup command, and bar settings remain configurable.
