# NixOS setup

This guide covers two routes: [install with the graphical installer](#a-graphical-installer), then adopt this flake; or [install entirely from a terminal](#b-terminal-only-installation) using the minimal ISO. Both use the same host configuration. A minimal installer can still install a desktop: `fear` and `laptop` enable Hyprland.

The flake targets **x86-64 machines booted in UEFI mode**, with the EFI partition mounted at `/boot`. Download the matching image from [NixOS downloads](https://nixos.org/download/). The current boot module does not configure Secure Boot signing.

| Host | Role | Default kernel | Host files |
| --- | --- | --- | --- |
| `fear` | Desktop, gaming, Hyprland | CachyOS | [`fear`](../../nix/nixos/hosts/fear) |
| `laptop` | Laptop, Hyprland | Latest Nixpkgs kernel | [`laptop`](../../nix/nixos/hosts/laptop) |
| `worker` | Existing homelab profile | Latest Nixpkgs kernel | [`worker`](../../nix/nixos/hosts/worker) |

These are personal machine profiles. Select one as a starting point and review its applications, peripherals, account names, and mounts before installing it on different hardware. `worker` includes homelab services; it is not a minimal terminal-only profile. Homelab setup is outside this guide; its existing configuration must evaluate successfully before installation.

## A. Graphical installer

1. Boot the graphical ISO in UEFI mode, connect to the network, and complete the installer. Use `mazilious` as the login name to match this repository, or change the repository's username references later. For a simple install matching these hosts, use an ext4 root filesystem and an EFI partition mounted at `/boot`. The [graphical installation manual](https://nixos.org/manual/nixos/stable/#sec-installation-graphical) explains the installer screens.
2. Reboot into the installed system and log in. Open a terminal, or use a text console if you chose “No desktop”. Keep the generated `/etc/nixos/configuration.nix` and hardware file as references.
3. Enter a root shell and obtain the editing tools:

   ```sh
   sudo -i
   nix-shell -p git nano
   export NIX_CONFIG='experimental-features = nix-command flakes'
   repo=/etc/nixos/dotfiles
   generatedHardware=/etc/nixos/hardware-configuration.nix
   ```

Continue at [Prepare the host configuration](#prepare-the-host-configuration). This route uses `nixos-rebuild`, not `nixos-install`; do not run the disk preparation commands below on the installed system.

## B. Terminal-only installation

Boot the minimal ISO in UEFI mode. You can also follow this route from a terminal in the graphical live ISO without running its graphical installer. All commands below run on the machine being installed.

### Connect to the network

Enter a root shell and confirm the boot mode:

```sh
sudo -i
test -d /sys/firmware/efi && echo 'UEFI boot confirmed'
ip -br address
```

If the UEFI check does not print the confirmation, reboot the USB in UEFI mode before proceeding. Wired networking normally obtains an address automatically.

For Wi-Fi, use `nmtui` if the live image provides NetworkManager. On the minimal image, use its `wpa_supplicant` service instead:

```sh
systemctl start wpa_supplicant
wpa_cli
```

At the interactive `wpa_cli` prompt, enter the following, replacing the SSID and password. Use the network number returned by `add_network` if it is not `0`:

```text
add_network
set_network 0 ssid "YOUR_SSID"
set_network 0 psk "YOUR_WIFI_PASSWORD"
enable_network 0
status
quit
```

Wait for `wpa_state=COMPLETED`. This configures the live session; the installed hosts use NetworkManager. See the [installation networking guide](https://wiki.nixos.org/wiki/NixOS_Installation_Guide/en#Networking) for other network types.

Check connectivity, then obtain the tools:

```sh
ping -c 3 nixos.org
nix-shell -p git nano parted dosfstools e2fsprogs
export NIX_CONFIG='experimental-features = nix-command flakes'
```

### Prepare the disk

The following example creates a **new, unencrypted, single-disk installation** with a 1 GiB EFI partition and the remaining space as ext4. **It erases the selected disk.** For dual boot, existing partitions, encryption, or a separate home filesystem, follow the [manual installation guide](https://nixos.org/manual/nixos/stable/#sec-installation-manual) and mount the resulting root at `/mnt` and EFI partition at `/mnt/boot` before continuing.

Identify the target by its model and size. Do not select the installer USB:

```sh
lsblk -o NAME,PATH,SIZE,MODEL,FSTYPE,MOUNTPOINTS
```

Set the three device paths to match that disk. These placeholders deliberately do not identify a real disk. For example, NVMe partitions end in `p1` and `p2`, while SATA partitions typically end in `1` and `2`.

```sh
installDisk=/dev/REPLACE_WITH_TARGET_DISK
efiPartition=/dev/REPLACE_WITH_EFI_PARTITION
rootPartition=/dev/REPLACE_WITH_ROOT_PARTITION
```

After checking the selected disk and backing up any data you need:

```sh
parted --script "$installDisk" -- mklabel gpt
parted --script "$installDisk" -- mkpart ESP fat32 1MiB 1025MiB
parted --script "$installDisk" -- set 1 esp on
parted --script "$installDisk" -- mkpart root ext4 1025MiB 100%
udevadm settle
lsblk -o NAME,PATH,SIZE,FSTYPE,MOUNTPOINTS "$installDisk"
```

Verify that `efiPartition` and `rootPartition` match the two new partitions, then format and mount them:

```sh
mkfs.fat -F 32 -n EFI "$efiPartition"
mkfs.ext4 -L nixos "$rootPartition"
mount "$rootPartition" /mnt
mkdir -p /mnt/boot
mount -o umask=077 "$efiPartition" /mnt/boot
findmnt -R /mnt
nixos-generate-config --root /mnt
repo=/mnt/etc/nixos/dotfiles
generatedHardware=/mnt/etc/nixos/hardware-configuration.nix
```

This example does not create swap. Configure swap separately if you need it, especially for hibernation. Continue below in the same shell.

## Prepare the host configuration

Both routes now have a root shell with `repo` and `generatedHardware` set. Choose the existing flake output you will install, then clone the repository:

```sh
targetHost=fear  # or laptop; worker is the existing homelab profile
git clone https://github.com/mfalicoff/dotfiles.git "$repo"
cd "$repo"
cp "$generatedHardware" "nix/nixos/hosts/$targetHost/hardware-configuration.nix"
nano flake.nix "nix/nixos/hosts/$targetHost/system.nix" "nix/nixos/hosts/$targetHost/home.nix"
```

If a checkout already exists, use and review it instead of cloning over it. The clone must contain the bundle and kernel changes described here; if those changes are still local, transfer your reviewed checkout or use the branch containing them before installing.

Review the following repository-specific settings:

- **Hardware:** use the generated filesystem UUIDs and hardware modules. Never install using the committed disk UUIDs from another machine. Carry over any required encryption, storage, or driver settings from the installer's generated configuration.
- **User:** `flake.nix` defines `username = "mazilious"`. The laptop Home Manager file and some modules also contain that name directly. Search for `mazilious` if using a different account, and ensure `home.username` and `home.homeDirectory` match.
- **State versions:** preserve the `system.stateVersion` and `home.stateVersion` values when adopting this flake on an existing installation. For a new machine, choose them deliberately; do not increase them just because you update inputs.
- **Bundles:** select the desired domains in `system.nix` and `home.nix`. Use switches such as `development.cloud.enable` and `shellOptions.zsh.enable`; the bundles own their package lists. See the [bundle guide](../modules/home.md).
- **Desktop:** review monitor names, resolutions, GPU settings, and startup commands in the chosen host. Installing from a text console does not require disabling its desktop bundles.
- **Kernel:** `fear` selects `bootManager.kernel = "cachyos"`. Choices are `default`, `latest`, `zen`, and `cachyos`; see [kernel selection](../modules/README.md#kernel-selection).
- **Secrets and mounts:** `fear` and `worker` require an existing age identity for their encrypted secrets. Restore it as described below. Review machine-specific SMB mounts before enabling them on another network.

Git flakes include modified tracked files but omit new untracked files. Stage any new configuration files you intend to use, and inspect both staged and unstaged changes. Do not stage private keys:

```sh
git add "nix/nixos/hosts/$targetHost/hardware-configuration.nix"
git diff
git diff --cached
```

### Prepare the CachyOS cache

Initialize the cache arguments in this shell:

```sh
kernelCache=()
```

If the host selects `cachyos`, set them to the [kernel provider's cache](https://github.com/xddxdd/nix-cachyos-kernel#binary-cache). The new system's cache settings are not active during its initial installation or first rebuild:

```sh
kernelCache=(
  --option extra-substituters https://attic.xuyh0120.win/lantian
  --option extra-trusted-public-keys 'lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc='
)
```

Leave the array empty for the other kernel choices. Evaluate the selected system before installing or switching:

```sh
nix eval --raw ".#nixosConfigurations.${targetHost}.config.system.build.toplevel.drvPath" "${kernelCache[@]}"
```

Resolve evaluation errors before proceeding. Evaluation checks the configuration; it does not build packages or test hardware.

## Finish A: adopt the flake on the installed system

Run these commands only for route A, from the checkout on the installed system. Restore any required age identity to `/home/mazilious/.config/sops/age/keys.txt` before activation; see [secrets](#secrets-on-fear-and-worker).

```sh
nixos-rebuild build --flake ".#$targetHost" "${kernelCache[@]}"
nixos-rebuild boot --flake ".#$targetHost" "${kernelCache[@]}"
passwd mazilious
reboot
```

Replace the account name if you changed it. `boot` prepares the configuration for the next startup so adopting the flake does not replace your desktop session in place. Reboot to start the selected desktop and kernel. The flake now supplies the configuration; `/etc/nixos/configuration.nix` is not automatically imported by it.

## Finish B: install from the live session

Run these commands only for route B, with the target still mounted at `/mnt`:

```sh
nixos-install --root /mnt --flake "$repo#$targetHost" "${kernelCache[@]}"
nixos-enter --root /mnt -c 'passwd mazilious'
```

`nixos-install` prompts for the root password. The second command sets the normal user's password; replace `mazilious` if you changed the account. Restore any required age identity into the mounted target before rebooting, as described below. After all steps succeed:

```sh
cd /
umount -R /mnt
reboot
```

Remove the installer USB when the machine restarts. The checkout is now at `/etc/nixos/dotfiles` on the installed machine.

## Secrets on `fear` and `worker`

The system expects the existing age identity at `/home/mazilious/.config/sops/age/keys.txt`. Restore it from your secure backup; a newly generated key will not decrypt files encrypted for the old identity. The encrypted files and recipient configuration are described in the existing [secrets guide](../modules/homelab.md#secrets). `laptop` does not import sops-nix.

For route B, after `nixos-install`, copy the key into the target from a mounted backup. Replace `/path/to/backup/keys.txt` with its actual location:

```sh
install -d -m 700 /mnt/home/mazilious/.config/sops/age
install -m 600 /path/to/backup/keys.txt /mnt/home/mazilious/.config/sops/age/keys.txt
nixos-enter --root /mnt -c 'chown -R mazilious:users /home/mazilious/.config/sops'
```

For route A, use `/home/mazilious` instead of `/mnt/home/mazilious` and run `chown` directly on the installed system. Adjust the account name throughout if needed. Keep this private key outside the repository.

## After the first boot

Log in with the password you set. If using Wi-Fi, reconnect with `nmtui` on the installed host; the live installer's Wi-Fi configuration is not copied by this guide. Check the kernel and failed services:

```sh
uname -r
systemctl --failed
```

If the desktop cannot start, use `Ctrl+Alt+F2` to log in at a console. For a kernel or boot regression, select a previous NixOS generation in GRUB. A fresh manual install initially has only one generation; boot the installer USB again, mount root and EFI as above, correct the checkout, and rerun `nixos-install` without repartitioning or formatting.

## Subsequent rebuilds

For the root-owned checkout created by this guide:

```sh
sudo -i
cd /etc/nixos/dotfiles
targetHost=fear  # match this machine
nixos-rebuild build --flake ".#$targetHost"
nixos-rebuild switch --flake ".#$targetHost"
```

The CachyOS cache is configured after the first activation, so the initial cache arguments are no longer needed. Reboot after changing kernels. Always pass the flake explicitly when using this checkout. The root [`JustFile`](../../JustFile) also provides rebuild and evaluation recipes.
