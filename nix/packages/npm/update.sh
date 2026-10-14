#!/usr/bin/env bash
set -euo pipefail

package_dir="$(cd "$(dirname "$0")" && pwd)"
update_dir="$(mktemp -d)"
trap 'rm -rf "$update_dir"' EXIT

cp "$package_dir/package.json" "$update_dir/package.json"
if [[ -f "$package_dir/package-lock.json" ]]; then
  cp "$package_dir/package-lock.json" "$update_dir/package-lock.json"
fi

# Passing a package adds it at an exact version; no arguments refresh the lock.
(
  cd "$update_dir"
  npm install --package-lock-only --save-exact \
    --legacy-peer-deps --ignore-scripts --no-audit --no-fund "$@"
)
deps_hash="$(NPM_FETCHER_VERSION=2 prefetch-npm-deps "$update_dir/package-lock.json")"
if [[ ! "$deps_hash" =~ ^sha256-[A-Za-z0-9+/]{43}=$ ]]; then
  echo "prefetch-npm-deps did not return a valid dependency hash" >&2
  exit 1
fi

# Leave the checked-in files alone unless both resolution and fetching succeed.
cp "$update_dir/package.json" "$package_dir/package.json"
cp "$update_dir/package-lock.json" "$package_dir/package-lock.json"
printf '%s\n' "$deps_hash" > "$package_dir/npm-deps-hash"
