# macOS setup with nix-darwin

The root flake exposes `darwinConfigurations.fearful` for an Apple Silicon (`aarch64-darwin`) Mac. The host's [`system.nix`](../../nix/nixos/hosts/fearful/system.nix) selects macOS settings, Homebrew apps, and Stylix. Its [`home.nix`](../../nix/nixos/hosts/fearful/home.nix) selects Home Manager features and imports shared modules plus the host's [`plist.nix`](../../nix/nixos/hosts/fearful/plist.nix).

## Fresh machine

1. Confirm the Mac is Apple Silicon and that the local account matches `username = "mazilious"` in [`flake.nix`](../../flake.nix). Change that value and any `/Users/mazilious` paths before building for another account.
2. Install the [Nix package manager](https://nix.dev/install-nix) and [Homebrew](https://docs.brew.sh/Installation). Homebrew must be available before the first switch because the host enables `homebred` and declares brews, casks, and App Store apps. Sign in to the App Store for those apps. The Nix installer command for macOS is:

   ```sh
    curl -sSf -L https://install.lix.systems/lix | sh -s -- install
   ```
3. Enable `nix-command` and `flakes` in `/etc/nix/nix.conf` if the Nix installer has not already done so:

   ```conf
   experimental-features = nix-command flakes
   ```

4. Clone this repository and run from its root:

   ```sh
   mkdir -p ~/source
   git clone https://github.com/mfalicoff/dotfiles.git ~/source/dotfiles
   cd ~/source/dotfiles
   nix build .#darwinConfigurations.fearful.system
   sudo nix run github:LnL7/nix-darwin/master#darwin-rebuild -- switch --flake .#fearful
   ```

   Review the build before the switch. The first switch uses the [nix-darwin installation command](https://github.com/nix-darwin/nix-darwin#flakes-recommended-for-beginners), adapted to this flake's host name. If the build fails, resolve it before switching. Git flakes also require newly added source files to be tracked.

## Subsequent rebuilds

```sh
nix build .#darwinConfigurations.fearful.system
sudo darwin-rebuild switch --flake .#fearful
```

Nixpkgs manages CLI tools, fonts, and (through Home Manager) VS Code. nix-darwin makes Nix-installed app bundles available in `/Applications/Nix Apps`. The `homebred` module owns the Homebrew formulae, casks, and App Store app list in `fearful/system.nix`; its activation defaults to `cleanup = "uninstall"` and does not update Homebrew itself (`autoUpdate = false`); set `cleanup = "zap"` to also delete app data, and review removed entries before a switch. Zed is declared as a Homebrew cask. Home Manager owns shell, Git, Ghostty, and television settings; the television source files are in [`hosts/darwin/config/television`](../../nix/nixos/hosts/darwin/config/television). Existing Home Manager target files are backed up with a `.pre-nix` suffix during activation.

After switching, check the installed apps and CLI tools before removing any old manually installed copies. If a Nix GUI package does not build or launch, its declaration can be moved from [`modules/system/nix-darwin/default.nix`](../../nix/nixos/modules/system/nix-darwin/default.nix) to `homebred.casks` in the host's `system.nix`, then rebuilt.

Both Mac configurations use the shared Podman development bundle. `fearful` no longer declares OrbStack, and the work Mac no longer declares the Homebrew Docker CLI. After rebuilding, open a new shell and run `podman machine init` once, then `podman machine start`. To install Podman Desktop through Nix as well, enable `development.containers.desktop.enable` in the host's home configuration. The [container guide](../modules/home.md#containers) covers Compose commands, Docker API tools, and existing container data.

Aerofi is installed from the upstream `frostymur/tap` Homebrew tap. Its structured `homebrew.brews` entry in `fearful/system.nix` starts the launcher as a user service at login and restarts it when the formula changes. After switching, press the configured launcher shortcut (`Cmd+G`) to open it. Custom themes and scripts live in `~/.config/aerofi/`.

Home Manager installs [`config/aerofi/config.toml`](../../nix/nixos/hosts/darwin/config/aerofi/config.toml) as `~/.config/aerofi/config.toml` and [`config/aerofi/theme.toml`](../../nix/nixos/hosts/darwin/config/aerofi/theme.toml) as `~/.config/aerofi/themes/dotfiles.toml`. The selected theme uses Catppuccin Mocha colors and a footer with keyboard hints and a reload button. Edit these repository files and rebuild, then press `Cmd+R` in Aerofi to reload. Restart the service with `brew services restart aerofi` after changing global hotkeys. These two files are read-only Nix store links; scripts, plugins, and runtime state remain writable, and theme-switching scripts should not rewrite the managed config.

Aerofi scans only the immediate contents of each app directory, so `apps.extra_dirs` explicitly includes `~/Applications/Home Manager Apps` as well as `/Applications/Nix Apps`. Home Manager also runs [`cache-icons.py`](../../nix/nixos/hosts/darwin/config/aerofi/cache-icons.py) after linking the configuration to seed missing app icons from bundle resources using macOS `sips`. This fallback targets Aerofi 0.2.22's v4 icon cache and skips newer cache formats. The theme uses an explicit icon slot with 32-point icons. Reload Aerofi after rebuilding to pick up newly discovered apps and cached icons.

Home Manager creates the writable script directory (`~/.config/aerofi/scripts`) and plugin directory (`~/Library/Application Support/aerofi/plugins`) during activation so Aerofi can watch them even when empty. The app scan excludes `~/.nix-profile/Applications`, which is absent on these setups; Nix apps are discovered through the directories above.

## Work Mac (`MFALICOFF-MAC`)

`darwinConfigurations.MFALICOFF-MAC` is an adopt-only configuration for an MDM-managed Mac whose account is `mfalicoff` (`workUsername` in [`flake.nix`](../../flake.nix)). Its files are in [`nix/nixos/hosts/darwin/work`](../../nix/nixos/hosts/darwin/work). It manages only the Nix daemon settings, `/etc` shell hooks and Home Manager itself: no hostname, macOS defaults, Stylix, Homebrew (`homebred` would zap existing casks), dotfiles or Git config. Enable shared Home Manager features in its `home.nix` one at a time, switching after each. The `development.git` module deletes `~/.gitconfig` and uses personal defaults, so set `userEmail` before enabling it.

The host name used by `darwin-rebuild` does not match the Mac's local host name, so always pass the flake attribute explicitly.

First switch:

1. Build first: `nix build .#darwinConfigurations.MFALICOFF-MAC.system`. Git flakes ignore untracked files, so `git add` new files first.
2. Move the files nix-darwin refuses to overwrite:

   ```sh
   for f in /etc/bashrc /etc/zshrc /etc/zshenv /etc/nix/nix.conf; do sudo mv "$f" "$f.before-nix-darwin"; done
   ```

3. `sudo nix run github:LnL7/nix-darwin/master#darwin-rebuild -- switch --flake .#MFALICOFF-MAC`

Later rebuilds use `sudo darwin-rebuild switch --flake .#MFALICOFF-MAC`. The existing `~/.zshrc`, `~/.gitconfig` and installed apps are left alone.
