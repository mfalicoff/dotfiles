# macOS setup with nix-darwin

The root flake exposes `darwinConfigurations.fearful` for an Apple Silicon (`aarch64-darwin`) Mac. The host's [`system.nix`](../../nix/nixos/hosts/fearful/system.nix) selects macOS settings, Homebrew apps, and Stylix. Its [`home.nix`](../../nix/nixos/hosts/fearful/home.nix) imports shared Home Manager modules plus [`nix/darwin/home.nix`](../../nix/darwin/home.nix) and [`plist.nix`](../../nix/darwin/plist.nix).

## Fresh machine

1. Confirm the Mac is Apple Silicon and that the local account matches `username = "mazilious"` in [`flake.nix`](../../flake.nix). Change that value and any `/Users/mazilious` paths before building for another account.
2. Install the [Nix package manager](https://nix.dev/install-nix) and [Homebrew](https://docs.brew.sh/Installation). Homebrew must be available before the first switch because the host enables `homebred` and declares brews, casks, and App Store apps. Sign in to the App Store for those apps. The Nix installer command for macOS is:

   ```sh
   curl -L https://nixos.org/nix/install | sh
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

Nixpkgs manages CLI tools, fonts, and VS Code. nix-darwin makes Nix-installed app bundles available in `/Applications/Nix Apps`. The `homebred` module owns the Homebrew formulae, casks, and App Store app list in `fearful/system.nix`; its activation uses `cleanup = "zap"`, so review removed entries before a switch. Zed is declared as a Homebrew cask. Home Manager owns shell, Git, Ghostty, and television settings; the television source files are in [`nix/darwin/config`](../../nix/darwin/config). Existing Home Manager target files are backed up with a `.pre-nix` suffix during activation.

After switching, check the installed apps and CLI tools before removing any old manually installed copies. If a Nix GUI package does not build or launch, its declaration can be moved from [`modules/system/nix-darwin/default.nix`](../../nix/nixos/modules/system/nix-darwin/default.nix) to `homebred.casks` in the host's `system.nix`, then rebuilt.
