"""Seed Aerofi's v4 icon cache from app bundle resources using macOS sips."""

import argparse
from pathlib import Path
import plistlib
import subprocess
import tempfile
import tomllib


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("config", type=Path)
    parser.add_argument("--cache-dir", type=Path,
                        default=Path.home() / "Library/Caches/aerofi/icons")
    args = parser.parse_args()
    with args.config.open("rb") as file:
        config = tomllib.load(file)
    if not config.get("sources", {}).get("apps", True):
        return

    cache = args.cache_dir
    version = cache / "VERSION"
    # Aerofi 0.2.22 uses v4. Leave caches from newer formats to Aerofi.
    if version.exists() and version.read_text().strip() != "4":
        print("Aerofi icon cache format changed; skipping v4 fallback")
        return
    cache.mkdir(parents=True, exist_ok=True)
    version.write_text("4")

    directories = ["/Applications", "/Applications/Utilities",
                   "/System/Applications", "/System/Applications/Utilities",
                   "~/Applications", "~/Applications/Utilities"]
    directories += config.get("apps", {}).get("extra_dirs", [])
    bundles = [app for directory in directories
               for app in Path(directory).expanduser().glob("*.app")]
    bundles += [Path(app).expanduser()
                for app in config.get("apps", {}).get("extra_apps", [])]
    generated = 0
    for app in bundles:
        name = "".join(c if c.isalnum() or c in "-_" else "_"
                       for c in app.stem)
        destination = cache / f"{name}.tiff"
        if destination.exists():
            continue
        try:
            with (app / "Contents/Info.plist").open("rb") as file:
                info = plistlib.load(file)
        except (OSError, plistlib.InvalidFileException, ValueError):
            continue
        icon_name = info.get("CFBundleIconFile")
        if not isinstance(icon_name, str) or not icon_name:
            continue
        resources = app / "Contents/Resources"
        icon = resources / icon_name
        if not icon.is_file():
            icon = resources / f"{icon_name}.icns"
        if not icon.is_file():
            continue
        with tempfile.TemporaryDirectory(dir=cache) as directory:
            output = Path(directory) / "icon.tiff"
            result = subprocess.run(
                ["/usr/bin/sips", "-s", "format", "tiff",
                 "--resampleHeightWidth", "96", "96", str(icon),
                 "--out", str(output)], capture_output=True,
            )
            if result.returncode == 0 and output.is_file():
                output.replace(destination)
                generated += 1
    print(f"Aerofi: cached {generated} missing app icons")


if __name__ == "__main__":
    main()
