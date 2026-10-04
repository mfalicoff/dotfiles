# Dotfiles and Nix systems

The root [flake](flake.nix) is the active configuration for `fearful` (macOS)
and the existing NixOS hosts. The NixOS host and module hierarchy lives under
`nix/nixos`.

## macOS (`fearful`)

The `fearful` host selects its settings in `nix/nixos/hosts/fearful/system.nix`.
That host imports the user, Homebrew, Stylix, and macOS system modules under
`nix/nixos/modules/system`. Its Home Manager entry point is
`nix/nixos/hosts/fearful/home.nix`, which imports the shared home modules and
the macOS settings in `nix/darwin/home.nix`.

- Nixpkgs manages the CLI tools, fonts, and VS Code. nix-darwin places the
  VS Code app bundle in `/Applications/Nix Apps`.
- nix-darwin's Homebrew module manages the remaining macOS applications and
  the App Store apps. Zed uses its prebuilt Homebrew cask because this pinned
  Nix package has no Apple Silicon binary substitute and takes a long time to
  compile. Homebrew must already be installed.
- Home Manager owns the shell, Git, Ghostty, and television settings. Shared
  development tools and Git configuration come from `nix/nixos/modules/home/development`,
  while the Ghostty and television source files remain under `nix/darwin/config`.
  On the first switch, existing target files are renamed with a `.pre-nix`
  suffix.
- nix-darwin's built-in application activation makes Nix-installed `.app`
  bundles available in `/Applications/Nix Apps`; Homebrew casks install their
  app bundles in `/Applications`. The old custom app copier is not imported.

Nix is installed on this Mac, although a shell may need to load its profile
before `nix` is on `PATH`. Add or commit new files first (Git flakes omit
untracked files), then from this repository run:

```sh
nix build .#darwinConfigurations.fearful.system
sudo nix run github:nix-darwin/nix-darwin#darwin-rebuild -- switch --flake .#fearful
```

Check the build result before switching. Subsequent changes can use
`sudo darwin-rebuild switch --flake .#fearful`. The locked inputs came from the
older flake; update and test them on the Mac after the first successful build.
If a Nix GUI package fails to build or launch, move that entry from
`environment.systemPackages` in `nix/nixos/modules/system/nix-darwin/default.nix`
to `homebred.casks` in `nix/nixos/hosts/fearful/system.nix` and rebuild.

After a successful switch, verify the Nix versions of CLI tools, fonts, and VS
Code before uninstalling their old Homebrew copies. Homebrew activation uses
the supported `--force-cleanup` flag, so removed brews and casks are
uninstalled automatically. Keep the fallback brews, casks, and App Store apps
declared in `nix/nixos/hosts/fearful/system.nix`.

## NixOS

The root flake also exposes `fear`, `laptop`, and `worker`, using their
host-specific files and option modules under `nix/nixos`:

- `hosts/<name>/system.nix` and `home.nix` select features for each machine;
  their hardware configurations remain host-specific.
- `modules/system` defines reusable options for boot, gaming, homelab
  services, secrets, networking, styling, virtualization, and the desktop.
- `modules/home` defines reusable options for browsers, development tools,
  editors, shell, rofi, and window managers.
- `secrets` and `.sops.yaml` retain the encrypted service secrets and key
  rules. `JustFile` retains the host and secret-management recipes, now
  targeting the root flake.

The standalone .NET and Node development shell is in
`nix/shells/dotnet_npm` with its own flake lock.

All three NixOS system derivations evaluate from the root flake. Rebuild a
selected host on that machine with `sudo nixos-rebuild switch --flake .#fear`
(substitute its actual host name). Review its hardware configuration first;
the Linux systems have not been built or boot-tested on their target machines.
