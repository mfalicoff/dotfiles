# Backport Fabric's unreleased Invoke 3 compatibility fix for Azure CLI.
# https://github.com/fabric/fabric/issues/2376
final: prev: {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (_pythonFinal: pythonPrev: {
        fabric = pythonPrev.fabric.overridePythonAttrs (old: {
          patches =
            (old.patches or [])
            ++ [
              (final.fetchurl {
                url = "https://github.com/fabric/fabric/commit/7fa309db9dd5dac69079c1fb83b6f579555f7d53.patch";
                hash = "sha256-Y6IujOEvoNRstQrq4ZfdBjqkd1hI6lGYDhFbae9iAGI=";
              })
            ];
          pythonRelaxDeps = (old.pythonRelaxDeps or []) ++ ["invoke"];
          # The patch above addresses the reason for nixpkgs' broken marker.
          meta = old.meta // {broken = false;};
        });
      })
    ];
}
