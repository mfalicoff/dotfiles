# Module index

The root [flake](../../flake.nix) wires shared modules into each host. The `system.nix` and `home.nix` files in [`nix/nixos/hosts`](../../nix/nixos/hosts) choose what each machine enables. Most modules declare an option that does nothing until its `enable` flag is set.

## NixOS system modules

The [`modules/system/default.nix`](../../nix/nixos/modules/system/default.nix) import list is used by `fear` and `worker`. `laptop` imports a smaller set directly. `fearful` uses only the applicable shared modules plus the macOS modules described below.

| Module | Main option or purpose | Source |
| --- | --- | --- |
| Bootloader | `bootManager.enable`, `bootManager.kernel`; [kernel choices](#kernel-selection) | [boot](../../nix/nixos/modules/system/boot/default.nix) |
| Calibre | `calibre.enable` | [calibre](../../nix/nixos/modules/system/calibre/default.nix) |
| Gaming | `gaming.enable`; `launchers`, `emulation`, `performance`, `streaming` bundles | [gaming](../../nix/nixos/modules/system/gaming/default.nix) |
| Login | `loginManager.enable` | [greetd](../../nix/nixos/modules/system/greetd/default.nix) |
| Homelab | `homelab.enable` and child options; [guide](homelab.md) | [homelab](../../nix/nixos/modules/system/homelab/default.nix) |
| Hyprland system | `wm.hyprland.enable`; optional `tools` and `portals` bundles | [hyprland](../../nix/nixos/modules/system/hyprland/default.nix) |
| Password manager | `passwordManager.enable`; `onePassword` and `desktopIntegration` bundles | [password-manager](../../nix/nixos/modules/system/password-manager/default.nix) |
| Secrets | sops-nix file and age key settings | [secrets](../../nix/nixos/modules/system/secrets/default.nix) |
| SMB | `smb.enable`, `smb.server`, `smb.shares` | [smb](../../nix/nixos/modules/system/smb/default.nix) |
| SSH server | `sshServer.enable` | [ssh](../../nix/nixos/modules/system/ssh/default.nix) |
| Styling | `styling.stylix.enable` | [stylix](../../nix/nixos/modules/system/stylix/default.nix) |
| User | shared Linux user and groups | [user.nix](../../nix/nixos/modules/system/user.nix) |
| Virtualization | `virt.enable`; `virtualMachines` and `containers` bundles | [virtualization](../../nix/nixos/modules/system/virtualization/default.nix) |

The shared [`nix-core.nix`](../../nix/nixos/nix-core.nix) sets Nix features, unfree package access, and garbage collection.

## nix-darwin system modules

| Module | Purpose | Source |
| --- | --- | --- |
| Homebrew | `homebred.enable`, taps, brews, casks, and `appStoreApps` | [homebrew](../../nix/nixos/modules/system/homebrew/default.nix) |
| macOS defaults | `macos.enable`; `keyboard`, `login`, `desktop`, and `security` preferences | [nix-darwin](../../nix/nixos/modules/system/nix-darwin/default.nix) |
| Mac user | macOS user and shell | [host-users.nix](../../nix/nixos/hosts/fearful/host-users.nix) |
| Styling | Shared `styling.stylix.enable` | [stylix](../../nix/nixos/modules/system/stylix/default.nix) |

## Home Manager modules

These are imported through [`modules/home/default.nix`](../../nix/nixos/modules/home/default.nix). See the [Home Manager options guide](home.md) for examples and defaults.

| Module | Main option | Source |
| --- | --- | --- |
| Browsers | `browsers.enable` with Firefox, Zen, and Chrome | [browsers](../../nix/nixos/modules/home/browsers/default.nix) |
| Development | `development.enable` with cloud, containers, Kubernetes, Nix, Git, languages, and editor bundles | [development](../../nix/nixos/modules/home/development/default.nix) |
| Shell | `shellOptions.enable` with Zsh, terminal, navigation, monitoring, and tmux bundles | [shell](../../nix/nixos/modules/home/shell/default.nix) |
| Window manager | `windowManager.enable` with Hyprland and AeroSpace | [windowManager](../../nix/nixos/modules/home/windowManager/default.nix) |
| Rofi | `rofi.enable` | [rofi](../../nix/nixos/modules/home/rofi/default.nix) |

## Selecting system bundles

Each child bundle has an `enable` switch and owns its implementation defaults. Hosts select the responsibilities they need without repeating package lists or routine service settings:

```nix
{
  gaming = {
    enable = true;
    launchers.enable = true;   # Steam and Lutris
    emulation.enable = true;   # Ryubing and PCSX2
    performance.enable = true; # GameMode
    streaming.enable = false; # Sunshine
  };
  virt = {
    enable = true;
    virtualMachines.enable = false; # libvirt, virt-manager, SPICE
    containers.enable = true;       # Podman, Docker compatibility, network DNS
  };
}
```

Enabling a parent alone does not select these child bundles. Password management similarly separates the 1Password apps from desktop authentication/keyring integration. The Hyprland system bundle separates its supporting tools and desktop portals. macOS preferences separate keyboard, login appearance, desktop defaults, and Touch ID for sudo.

Boot, SSH, SMB, styling, Calibre, Rofi, and Homebrew retain their existing cohesive configuration. Homelab configuration is unchanged by this bundle refactor.

## Kernel selection

Choose a kernel per NixOS host in its `system.nix`:

```nix
bootManager = {
  enable = true;
  kernel = "cachyos";
};
```

| Choice | Kernel package set |
| --- | --- |
| `default` | Nixpkgs' default kernel (`linuxPackages`) |
| `latest` | Nixpkgs' latest stable kernel; the default for this option |
| `zen` | Nixpkgs' Zen kernel |
| `cachyos` | CachyOS latest release, generic x86-64 build |

`fear` selects CachyOS. Other hosts keep `latest`. Kernel selection is independent of `gaming.enable`. For a custom package set, NixOS's native `boot.kernelPackages` remains available with `lib.mkForce`.

CachyOS comes from the [community NixOS kernel provider](https://github.com/xddxdd/nix-cachyos-kernel#how-to-use-kernels) linked by CachyOS. The flake locks its `release` branch and retains its own Nixpkgs pin so the kernel matches the provider's builds. The module adds the provider's signed binary cache only when CachyOS is selected. This preset supports `x86_64-linux`; it does not assume a particular AMD or Intel CPU generation.

For the first rebuild on `fear`, pass the cache settings explicitly so they are available before the new configuration is activated:

```sh
sudo nixos-rebuild switch --flake .#fear \
  --option extra-substituters https://attic.xuyh0120.win/lantian \
  --option extra-trusted-public-keys 'lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc='
```

Reboot to start the selected kernel. A previous NixOS generation remains available in GRUB if you need to boot the previous kernel. No rebuild or reboot is performed by changing this file alone.

## Verification

Evaluate the bundle isolation checks using the locked flake inputs:

```sh
nix eval --impure --json --expr '
  let flake = builtins.getFlake ("path:" + toString ./.);
  in import ./tests/bundles.nix { inherit (flake) inputs; }
'
```

These checks exercise actual Home Manager and NixOS modules, including parent gating and independent bundle selection. System evaluation remains available through `just check-nixos <host>` and `just check-darwin fearful`.

Kernel selection checks use the same command with `./tests/kernels.nix` in place of `./tests/bundles.nix`. They cover all four choices, cache scoping, disabled boot configuration, and invalid selections.
