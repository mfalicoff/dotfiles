{
  config,
  lib,
  pkgs,
  ...
}: {
  options.development.kubernetes.enable = lib.mkEnableOption "kubernetes development tools";

  config = lib.mkIf (config.development.enable && config.development.kubernetes.enable) {
    home.packages = with pkgs; [
      argocd
      kubernetes-helm
      kustomize
      kubectx
      stern
      kubeconform
      kind
      k9s
      kubectl
      kubeseal
      talosctl
      kubelogin
    ];

    programs.sofka = {
      enable = true;
    };
  };
}
