# Home Manager options

The shared Home Manager modules live in [`nix/nixos/modules/home`](../../nix/nixos/modules/home). Set their options in a host's `home.nix`; macOS also sets shared options in [`nix/darwin/home.nix`](../../nix/darwin/home.nix). Parent `enable` switches must be on for child settings to take effect.

| Module | Common child switches | Defaults after enabling parent |
| --- | --- | --- |
| [`browsers`](../../nix/nixos/modules/home/browsers/default.nix) | `firefox`, `zen`, `chrome` | Each browser off |
| [`development`](../../nix/nixos/modules/home/development/default.nix) | `editors`, `sdk`, `tools`, `git` | Editors, tools, Git on; SDK off |
| [`shellOptions`](../../nix/nixos/modules/home/shell/default.nix) | `shell`, `shell.tmux` | Shell on; tmux off |
| [`windowManager`](../../nix/nixos/modules/home/windowManager/default.nix) | `wayland.hyprland`, `wayland.bar.waybar`, `aerospace` | Children off |

For example, within a host Home Manager module:

```nix
{
  development.tools.packages.azureCli = false;
  development.editors.vscode.extensions.zig = false;
  development.editors.zed.settings.vimMode = true;
  shellOptions.shell.features.launchTuios = false;
  shellOptions.shell.tmux.plugins.weather = false;
  browsers.firefox.extensions.ublockOrigin = false;
  browsers.zen.settings.trackingProtection = true;
  browsers.chrome.settings.startMaximized = true;
}
```

Bundled development tools, shell packages and plugins, editor extensions, and Firefox and Zen extensions start enabled when their component is enabled. These defaults are shared across platforms. Set an individual switch to `false` to leave it out. Optional browser settings still start disabled. Browser extensions create a managed `default` profile. The curated add-ons come from the pinned NUR overlay and may require browser approval after installation. Firefox and Zen have separate `extensions`, `settings`, and `advanced` options.

Each module also exposes `advanced` settings for items outside the curated list: `development.tools.advanced.extraPackages`, editor extensions and settings, `shellOptions.shell.advanced.shellAliases`, and browser profile settings. Advanced settings override bundled values for the same key. Chrome accepts `browsers.chrome.advanced.commandLineArgs`.

Zen is enabled on `fear` and `fearful` using the pinned [Zen Browser flake](https://github.com/0xc000022070/zen-browser-flake). On macOS, Home Manager copies `profiles.ini` to a writable file so Zen can complete profile setup. Both hosts disable `stylix.targets.zen-browser`; to style a managed profile, enable that target and set its `profileNames` to `[ "default" ]`.
