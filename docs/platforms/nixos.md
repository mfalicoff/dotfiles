# NixOS setup

The root flake exposes `nixosConfigurations.fear`, `.laptop`, and `.worker`. All three are `x86_64-linux`. A host's `system.nix` selects system modules, `home.nix` selects Home Manager modules, and `hardware-configuration.nix` contains disk and hardware details. See the [module index](../modules/README.md) for available features.

| Host | Role | Host files |
| --- | --- | --- |
| `fear` | Desktop, gaming, Hyprland | [`nix/nixos/hosts/fear`](../../nix/nixos/hosts/fear) |
| `laptop` | Laptop, Hyprland | [`nix/nixos/hosts/laptop`](../../nix/nixos/hosts/laptop) |
| `worker` | Homelab services | [`nix/nixos/hosts/worker`](../../nix/nixos/hosts/worker) |

## Fresh machine

1. Boot the [NixOS installer](https://nixos.org/download/), connect to the network, and partition and mount the target disks at `/mnt` following the [NixOS installation manual](https://nixos.org/manual/nixos/stable/#sec-installation). Mount the EFI system partition at `/mnt/boot` for these hosts.
2. Generate hardware settings, then clone this repository into the mounted system:

   ```sh
   sudo nixos-generate-config --root /mnt
   sudo git clone https://github.com/mfalicoff/dotfiles.git /mnt/etc/nixos/dotfiles
   ```

3. Choose the matching host and copy the *new machine's* generated hardware file into it. Check filesystem UUIDs, bootloader, network, GPU, and other host-specific settings before installing. The committed hardware files refer to the current machines and must not be reused blindly. For example:

   ```sh
   sudo cp /mnt/etc/nixos/hardware-configuration.nix \
     /mnt/etc/nixos/dotfiles/nix/nixos/hosts/fear/hardware-configuration.nix
   ```

4. In the cloned [`flake.nix`](../../flake.nix), check `username`, host name, and architecture. The configuration currently assumes the user `mazilious`. Update the chosen host's `system.nix` and `home.nix` to fit the machine.
5. Install with the matching flake output, then set the login password:

   ```sh
   sudo nixos-install --flake /mnt/etc/nixos/dotfiles#fear
   sudo nixos-enter --root /mnt -c 'passwd mazilious'
   ```

   Replace `fear` with `laptop` or `worker` when installing that host. On `fear` or `worker`, restore the age identity used by [sops-nix](../modules/homelab.md#secrets) to `/mnt/home/mazilious/.config/sops/age/keys.txt` before first boot. Keep it readable only by the configured user. Reboot after the install succeeds. The [NixOS manual](https://nixos.org/manual/nixos/stable/#sec-installation) covers recovery if installation fails.

Git flakes omit untracked files, so add a newly generated hardware file to Git before evaluating the local checkout. Review the diff before committing it.

## Rebuild an installed host

From this repository on the target machine, build first, then switch using its flake name:

```sh
nix build .#nixosConfigurations.fear.config.system.build.toplevel
sudo nixos-rebuild switch --flake .#fear
```

Substitute `laptop` or `worker` for `fear` as appropriate. The root [`JustFile`](../../JustFile) has rebuild and evaluation recipes; run `just --list` from the repository root to see them.

### Secrets on `fear` and `worker`

Those hosts import sops-nix and expect an age identity at `/home/mazilious/.config/sops/age/keys.txt`. Restore it securely with permissions limited to that user. Encrypted files are under [`nix/nixos/secrets`](../../nix/nixos/secrets), and their recipients are listed in [`nix/nixos/.sops.yaml`](../../nix/nixos/.sops.yaml). The `laptop` flake output does not import sops-nix.
