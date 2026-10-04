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

## Flake updates

[Renovate](https://github.com/apps/renovate) updates the root `flake.lock`, including a weekly lock file refresh. It groups root flake input updates and requests auto-merge only after the PR's checks pass. The standalone development shell flake is outside this automation.

The [Flake builds workflow](.github/workflows/flake-build.yml) builds the `fear`, `laptop`, and `worker` NixOS system closures on Linux and the `fearful` nix-darwin system closure on Apple Silicon. It runs on every PR, on pushes to `master`, and in merge queues. These builds catch evaluation and build failures; they do not test switching to the new configuration or running services on the machines.

To make passing builds a requirement for Renovate auto-merge, install the Renovate GitHub App for this repository and configure a GitHub ruleset for `master` that requires pull requests and these four status checks: `NixOS / fear`, `NixOS / laptop`, `NixOS / worker`, and `Darwin / fearful`. Select the checks after the workflow's first run makes them available. Require the branch to be up to date before merging, or use the merge queue, and do not give Renovate a ruleset bypass. Do not add a required review rule if updates should merge without manual approval. Renovate itself performs the merge after checks pass, so GitHub's **Allow auto-merge** switch is not needed.
