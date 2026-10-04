# Dotfiles and Nix systems

The root [flake](flake.nix) configures three NixOS machines and one Apple Silicon Mac. Each host selects its system and Home Manager features in `nix/nixos/hosts/<host>/system.nix` and `home.nix`.

| Host | Platform | Guide |
| --- | --- | --- |
| `fear` | NixOS desktop | [NixOS setup](docs/platforms/nixos.md) |
| `laptop` | NixOS laptop | [NixOS setup](docs/platforms/nixos.md) |
| `worker` | NixOS homelab | [NixOS setup](docs/platforms/nixos.md) |
| `fearful` | nix-darwin on Apple Silicon | [macOS setup](docs/platforms/nix-darwin.md) |

Start with the platform guide for a fresh install or rebuild. The [module index](docs/modules/README.md) shows where each reusable feature lives; the [Home Manager guide](docs/modules/home.md) explains its feature switches, and the [homelab guide](docs/modules/homelab.md) covers services and secrets.

From the repository root, after reviewing the matching platform guide:

```sh
sudo nixos-rebuild switch --flake .#fear       # on fear; use laptop or worker there
sudo darwin-rebuild switch --flake .#fearful   # on fearful
```

The standalone .NET and Node development shell is in [`nix/shells/dotnet_npm`](nix/shells/dotnet_npm) and has its own lock file.
