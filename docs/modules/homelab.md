# Homelab and secrets

The `worker` host enables `homelab` in [`worker/system.nix`](../../nix/nixos/hosts/worker/system.nix). The parent module imports backups, monitoring, a reverse proxy, and individual services; each child has its own `enable` option.

| Area | Option | Source |
| --- | --- | --- |
| Backups | `homelab.backups.enable` | [backups.nix](../../nix/nixos/modules/system/homelab/backups.nix) |
| Monitoring | `homelab.monitoring.enable` (Grafana, Loki) | [monitoring](../../nix/nixos/modules/system/homelab/monitoring/default.nix) |
| Reverse proxy | `homelab.reverseProxy.enable` | [reverseProxy.nix](../../nix/nixos/modules/system/homelab/reverseProxy.nix) |
| Services | `homelab.services.enable` | [services/default.nix](../../nix/nixos/modules/system/homelab/services/default.nix) |

The services module enables and assigns ports to its apps in one place; individual app implementations are in [`services/`](../../nix/nixos/modules/system/homelab/services). Backups use the SMB backups mount, so check `smb.server`, `smb.shares`, and the SMB credential before enabling them on another host.

## Secrets

`fear` and `worker` import sops-nix. The [`secrets` module](../../nix/nixos/modules/system/secrets/default.nix) reads encrypted files from [`nix/nixos/secrets`](../../nix/nixos/secrets) and expects an age identity at `/home/mazilious/.config/sops/age/keys.txt`. Its public recipients and creation rule are in [`nix/nixos/.sops.yaml`](../../nix/nixos/.sops.yaml). Keep the private identity outside Git; restore it on a fresh machine before starting services that use those secrets. When adding a new host, add its recipient and re-encrypt the files it must decrypt.
