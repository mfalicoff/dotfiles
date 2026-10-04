# Module index

The root [flake](../../flake.nix) wires shared modules into each host. The `system.nix` and `home.nix` files in [`nix/nixos/hosts`](../../nix/nixos/hosts) choose what each machine enables. Most modules declare an option that does nothing until its `enable` flag is set.

## NixOS system modules

The [`modules/system/default.nix`](../../nix/nixos/modules/system/default.nix) import list is used by `fear` and `worker`. `laptop` imports a smaller set directly. `fearful` uses only the applicable shared modules plus the macOS modules described below.

| Module | Main option or purpose | Source |
| --- | --- | --- |
| Bootloader | `bootManager.enable` | [boot](../../nix/nixos/modules/system/boot/default.nix) |
| Calibre | `calibre.enable` | [calibre](../../nix/nixos/modules/system/calibre/default.nix) |
| Gaming | `gaming.enable` | [gaming](../../nix/nixos/modules/system/gaming/default.nix) |
| Login | `loginManager.enable` | [greetd](../../nix/nixos/modules/system/greetd/default.nix) |
| Homelab | `homelab.enable` and child options; [guide](homelab.md) | [homelab](../../nix/nixos/modules/system/homelab/default.nix) |
| Hyprland system | `wm.hyprland.enable` | [hyprland](../../nix/nixos/modules/system/hyprland/default.nix) |
| NVIDIA | `hardware.graphics.nvidia.enable` | [nvidia](../../nix/nixos/modules/system/nvidia/default.nix) |
| Password manager | `passwordManager.enable` | [password-manager](../../nix/nixos/modules/system/password-manager/default.nix) |
| Secrets | sops-nix file and age key settings | [secrets](../../nix/nixos/modules/system/secrets/default.nix) |
| SMB | `smb.enable`, `smb.server`, `smb.shares` | [smb](../../nix/nixos/modules/system/smb/default.nix) |
| SSH server | `sshServer.enable` | [ssh](../../nix/nixos/modules/system/ssh/default.nix) |
| Styling | `styling.stylix.enable` | [stylix](../../nix/nixos/modules/system/stylix/default.nix) |
| User | shared Linux user and groups | [user.nix](../../nix/nixos/modules/system/user.nix) |
| Virtualization | `virt.enable` | [virtualization](../../nix/nixos/modules/system/virtualization/default.nix) |

The shared [`nix-core.nix`](../../nix/nixos/nix-core.nix) sets Nix features, unfree package access, and garbage collection.

## nix-darwin system modules

| Module | Purpose | Source |
| --- | --- | --- |
| Homebrew | `homebred.enable`, taps, brews, casks, and `appStoreApps` | [homebrew](../../nix/nixos/modules/system/homebrew/default.nix) |
| macOS defaults | System packages, keyboard, Finder, security, and plist settings | [nix-darwin](../../nix/nixos/modules/system/nix-darwin/default.nix) |
| Mac user | macOS user and shell | [host-users.nix](../../nix/nixos/hosts/fearful/host-users.nix) |
| Styling | Shared `styling.stylix.enable` | [stylix](../../nix/nixos/modules/system/stylix/default.nix) |

## Home Manager modules

These are imported through [`modules/home/default.nix`](../../nix/nixos/modules/home/default.nix). See the [Home Manager options guide](home.md) for examples and defaults.

| Module | Main option | Source |
| --- | --- | --- |
| Browsers | `browsers.enable` with Firefox, Zen, and Chrome | [browsers](../../nix/nixos/modules/home/browsers/default.nix) |
| Development | `development.enable` with tools, Git, SDKs, and editors | [development](../../nix/nixos/modules/home/development/default.nix) |
| Shell | `shellOptions.enable` with Zsh, Ghostty, and tmux | [shell](../../nix/nixos/modules/home/shell/default.nix) |
| Window manager | `windowManager.enable` with Hyprland and AeroSpace | [windowManager](../../nix/nixos/modules/home/windowManager/default.nix) |
| Rofi | `rofi.enable` | [rofi](../../nix/nixos/modules/home/rofi/default.nix) |
