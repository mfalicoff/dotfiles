{
  lib,
  buildNpmPackage,
  nodejs,
  makeWrapper,
  jq,
  nix,
  ffmpeg,
  stdenv,
  autoPatchelfHook,
}:
buildNpmPackage {
  pname = "dotfiles-npm-clis";
  version = "1.0.0";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [./package.json ./package-lock.json];
  };
  npmDepsHash = lib.removeSuffix "\n" (builtins.readFile ./npm-deps-hash);
  npmDepsFetcherVersion = 2;
  dontNpmBuild = true;
  # Use published binaries; avoid install scripts that download extra GPU SDKs.
  npmFlags = ["--legacy-peer-deps" "--ignore-scripts"];
  nativeBuildInputs = [makeWrapper jq] ++ lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [stdenv.cc.cc.lib];

  installPhase = ''
    runHook preInstall

    # ONNX bundles several platforms in one archive. Keep this host's binaries
    # so Linux ELF fixups don't try to patch other architectures.
    while IFS= read -r -d "" directory; do
      find "$directory" -mindepth 2 -maxdepth 2 -type d \
        ! -path '*/${stdenv.hostPlatform.node.platform}/${stdenv.hostPlatform.node.arch}' \
        -exec rm -rf {} +
    done < <(find node_modules -type d -path '*/onnxruntime-node/bin/napi-*' -prune -print0)

    mkdir -p "$out/lib/npm-clis" "$out/bin"
    cp -r node_modules "$out/lib/npm-clis/"

    # Expose only explicitly requested packages, with npm's scoped-name rules.
    while IFS= read -r package; do
      while IFS=$'\t' read -r name target; do
        if [[ -e "$out/bin/$name" ]]; then
          echo "Duplicate npm CLI name: $name" >&2
          exit 1
        fi
        makeWrapper "$out/lib/npm-clis/node_modules/$package/$target" "$out/bin/$name" \
          --prefix PATH : ${lib.makeBinPath [nodejs nix ffmpeg]}
      done < <(jq -r '
        if (.bin | type) == "string" then
          [[(.name | split("/") | last), .bin]]
        elif (.bin | type) == "object" then
          [.bin | to_entries[] | [.key, .value]]
        else [] end | .[] | @tsv
      ' "node_modules/$package/package.json")
    done < <(jq -r '.dependencies | keys[]' package.json)

    runHook postInstall
  '';

  meta.description = "Npm command-line tools from the dotfiles package list";
}
