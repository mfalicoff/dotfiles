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
      dotnet = {
        enable = true;
        rider.enable = true; # Optional JetBrains IDE
      };
    };
    editors = {
      enable = true;
      neovim.enable = true;
      vscode.enable = true;
      zed.enable = true;
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
| `languages.c` | GCC; optional CLion |
| `languages.python` | uv; optional PyCharm |
| `languages.dotnet` | .NET 10 SDK; optional Rider |
| `languages.javascript` | Node.js, JavaScript/TypeScript support; optional WebStorm |
| `languages.java` | JDK; optional IntelliJ IDEA |
| `languages.go` | Go; optional GoLand |
| `languages.php` | PHP, Composer; optional PhpStorm |
| `languages.ruby` | Ruby; optional RubyMine |
| `languages.sql` | SQL editor support; optional DataGrip |
| `languages.zig` | Zig |
| `languages.elixir` | Elixir |
| `editors` | Select Zed, Neovim, and VS Code separately |

Each area lives in its own file under [`development`](../../nix/nixos/modules/home/development). Language bundles live in `development/languages`. The old `development.sdk.enable` is now `development.languages.dotnet.enable`; the old mixed `development.tools` package selection is replaced by the bundles above.

Language bundles own their toolchains, editor extensions, Neovim language servers and syntax grammars, and optional JetBrains IDEs. For example, `languages.dotnet.enable = true` adds C# and CSharpier to enabled VS Code, the C# extension to enabled Zed, and `csharp_ls` plus the C# grammar to enabled Neovim. `development.nix.enable` supplies the Nix integrations in the same way. Language switches do not enable editors: set `editors.enable` and each desired editor's `enable` switch. Zed's built-in languages (C/C++, Python, JavaScript/TypeScript, and Go) use its built-in support with the corresponding language server packages.

JetBrains switches live under their languages, such as `languages.dotnet.rider.enable`, `languages.python.pycharm.enable`, and `languages.javascript.webstorm.enable`. Both the language and `development.enable` must be enabled; JetBrains IDEs do not require `editors.enable`. The old `editors.jetbrains` options have been removed, and the repository's hosts use the new paths. On `laptop`, .NET remains disabled, so its Rider selection is dormant until .NET is enabled.

Editors keep their shared UI, plugins, and general extensions. Existing Zed and VS Code `extensions`, `settings`, and `advanced` options remain available for exceptions. Language extensions default to the language's enablement and can be disabled individually, for example `editors.vscode.extensions.csharp = false` or `editors.zed.extensions.csharp = false`. These switches apply while the language is enabled. Native Neovim server options can override the defaults, and Zed's `advanced.settings` can override language settings. Zig and Elixir extensions now require their language bundles instead of being installed for every editor user.

## Neovim

Neovim stays declarative through Nixvim and uses LazyVim-style defaults: Snacks for the picker, explorer, dashboard, notifications, and indent guides; Blink.cmp with native snippets; Conform for formatting; Gitsigns, Flash, mini.ai/mini.pairs, Noice, Trouble, and Persistence. Catppuccin Mocha supplies lavender accents, subtle indent guides, and matching rounded popups. Lualine has rounded section separators, Bufferline uses the Catppuccin palette, and mini.icons supplies file icons. The centered dashboard includes shortcuts and recent files. Plugins and external tools are installed by Nix.

The leader is Space; the local leader is backslash. Root-aware actions locate the current file's project using Git, .NET, Node, Python, Go, Elixir, or Zig markers, with the current directory as fallback. Uppercase variants use the current working directory.

| Keys | Action |
| --- | --- |
| `Space ff` / `Space fF` | Find files in project / current directory |
| `Space /` / `Space sG` | Grep project / current directory |
| `Space e` / `Space E` | Explorer in project / current directory |
| `Space ,` | Buffer picker |
| `Ctrl h/j/k/l` | Move between windows |
| `Shift h/l` | Previous / next buffer |
| `Space bd` | Delete buffer while preserving the window layout |
| `Space cf` | Format buffer or visual selection |
| `Space ca` / `Space cr` | LSP code action / rename |
| `Space cd` / `Space xx` | Line diagnostics / Trouble diagnostics |
| `Space sr` | Search and replace across files |
| `Space gs` / `Space ghp` | Git status / preview hunk |
| `s` / `S` | Flash jump / Treesitter jump |
| `Space qs` / `Space ql` | Restore current / last session |
| `Space uf` / `Space uF` | Toggle formatting globally / for this buffer |
| `Space ft` | Project terminal |
| `Ctrl s` / `Space qq` | Save / quit all |

Formatting runs on save and falls back to the LSP when no external formatter is available. Lua, shell, JSON, YAML, and Markdown have shared formatters. Enabled language bundles add clang-format, Ruff, CSharpier, Prettier, google-java-format, goimports/gofmt, PHP CS Fixer, RuboCop, sql-formatter, zig fmt, mix format, or Alejandra as appropriate. Nixvim installs the configured formatter packages. Override individual language defaults through `programs.nixvim.plugins.conform-nvim.settings.formatters_by_ft`, including an empty list to use only the LSP fallback. `Space cf` still formats explicitly when automatic formatting is off.

Completion uses Blink's `enter` preset: arrow keys or `Ctrl n/p` select, Enter accepts the selection, `Ctrl y` selects and accepts, `Ctrl Space` opens completion, and Tab/Shift Tab move through snippet placeholders. Which-key displays the available groups after Space.

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
