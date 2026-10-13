# Npm CLI collection

All npm CLIs live in the `dependencies` list in [`npm/package.json`](npm/package.json).
One shared Nix builder installs their executables when `development.enable` and
`development.tools.enable` are enabled.

Add a CLI from the repository root:

```sh
just npm-add '@storyteller-platform/ghost-story'
just npm-add 'some-cli@1.2.3'
```

This pins the requested version, updates `npm/package-lock.json`, and calculates
`npm/npm-deps-hash` using the flake's locked Node.js and Nix fetcher. No new Nix
file or module edit is needed. The files are only replaced after fetching succeeds.
Rebuild your system as usual to install the new CLI.

You can also edit the dependency list directly, then run `just npm-lock`. Remove
a dependency from that list and run the same command to remove its executable.
Commit the manifest, lock, and hash together.

The builder supports published JavaScript CLIs and bundled native binaries.
It skips npm lifecycle scripts, so packages that require compilation or separate
binary downloads may need a shared build hook. Linux native libraries are fixed
up automatically. Wrappers provide Node.js, Nix, and FFmpeg on their command path.
Ghost Story retains its ONNX CPU libraries and Apple Silicon MLX module; speech
models and whisper.cpp binaries are installed by Ghost Story at runtime.
