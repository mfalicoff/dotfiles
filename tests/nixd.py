#!/usr/bin/env python3
"""Check real nixd completion using an exported Nix-generated settings object."""
import argparse
import json
import os
import queue
import subprocess
import tempfile
import threading
import time
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("settings", type=Path)
parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
parser.add_argument("--server", default="nixd")
args = parser.parse_args()
settings = json.loads(args.settings.read_text())
root = args.root.resolve()
messages = queue.Queue()
log = tempfile.TemporaryFile(mode="w+")
server = subprocess.Popen([args.server], cwd=root, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=log)
request_id = 0


def reader():
    try:
        while True:
            headers = {}
            while True:
                line = server.stdout.readline()
                if not line:
                    return
                if line in (b"\r\n", b"\n"):
                    break
                key, value = line.decode().split(":", 1)
                headers[key.lower()] = value.strip()
            size = int(headers["content-length"])
            messages.put(json.loads(server.stdout.read(size)))
    except Exception as error:
        messages.put({"reader_error": str(error)})


threading.Thread(target=reader, daemon=True).start()


def send(message):
    payload = json.dumps({"jsonrpc": "2.0", **message}).encode()
    server.stdin.write(f"Content-Length: {len(payload)}\r\n\r\n".encode() + payload)
    server.stdin.flush()


def notify(method, params):
    send({"method": method, "params": params})


def option_name(item):
    # nixd may offer separate snippets for an option's example and default.
    return item.get("filterText", item["label"].split(" (")[0])


def request(method, params, timeout=30):
    global request_id
    request_id += 1
    current = request_id
    send({"id": current, "method": method, "params": params})
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        try:
            message = messages.get(timeout=min(1, max(0.01, deadline - time.monotonic())))
        except queue.Empty:
            if server.poll() is not None:
                raise RuntimeError("nixd exited unexpectedly")
            continue
        if "reader_error" in message:
            raise RuntimeError(message["reader_error"])
        if "method" in message and "id" in message:
            result = None
            if message["method"] == "workspace/configuration":
                result = [settings if item.get("section") == "nixd" else {"nixd": settings}
                          for item in message["params"]["items"]]
            send({"id": message["id"], "result": result})
        elif message.get("id") == current and "method" not in message:
            if "error" in message:
                raise RuntimeError(f"{method}: {message['error']}")
            return message.get("result")
    raise TimeoutError(f"Timed out waiting for {method}")


try:
    request("initialize", {
        "processId": os.getpid(), "rootUri": root.as_uri(),
        "workspaceFolders": [{"uri": root.as_uri(), "name": root.name}],
        "capabilities": {
            "workspace": {"configuration": True},
            "textDocument": {"completion": {"completionItem": {"snippetSupport": True}}},
        },
    })
    notify("initialized", {})
    notify("workspace/didChangeConfiguration", {"settings": {"nixd": settings}})
    # Documents stay in memory. No edits are written to the user's configuration.
    uri = (root / "nix/nixos/hosts/fearful/home.nix").as_uri()
    scenarios = [
        ("development.languages.", {"dotnet", "python", "javascript", "elixir"}),
        ("development.languages.dotnet.", {"enable", "rider"}),
        ("shellOptions.", {"zsh", "terminal", "navigation", "tmux"}),
        ("macos.", {"enable", "keyboard", "desktop"}) if "darwinConfigurations" in settings["options"]["system"]["expr"]
        else ("bootManager.", {"enable", "kernel"}),
        ("browsers.zen.extensions.", {"ublockOrigin", "darkreader", "protonpass", "karakeep"}),
        ("browsers.zen.advanced.", {"extensions"}),
    ]
    # A cursor marker lets package expressions exercise RHS and `with` scopes too.
    scenarios = [
        (prefix, "{ config, pkgs, ... }: {\n  " + prefix + "| = {};\n}\n", expected)
        for prefix, expected in scenarios
    ] + [
        ("pkgs.hello", "{ pkgs, ... }: {\n  home.packages = [ pkgs.hell| ];\n}\n", {"hello"}),
        ("pkgs.lib", "{ pkgs, ... }: {\n  value = pkgs.lib.mkOpt|;\n}\n", {"mkOption"}),
        ("NUR addons", "{ pkgs, ... }: {\n  browsers.zen.advanced.extensions = [ pkgs.nur.repos.rycee.firefox-addons.| ];\n}\n",
         {"adblocker-ultimate"}),
    ] + [
        (f"NUR addon {name}", "{ pkgs, ... }: {\n  browsers.zen.advanced.extensions = [ pkgs.nur.repos.rycee.firefox-addons."
         + prefix + "| ];\n}\n", {name})
        for prefix, name in [("ublock-", "ublock-origin"), ("darkr", "darkreader"),
                             ("proton-p", "proton-pass"), ("karak", "karakeep")]
    ] + [
        ("NUR addons with scope", "{ pkgs, ... }: {\n  browsers.zen.advanced.extensions = with pkgs.nur.repos.rycee.firefox-addons; [ ublock-| ];\n}\n",
         {"ublock-origin"}),
    ]
    for version, (prefix, marked_text, expected) in enumerate(scenarios, 1):
        before, after = marked_text.split("|", 1)
        position = {"line": before.count("\n"), "character": len(before.rsplit("\n", 1)[-1])}
        text = before + after
        document = {"uri": uri, "languageId": "nix", "version": version, "text": text}
        if version == 1:
            notify("textDocument/didOpen", {"textDocument": document})
        else:
            notify("textDocument/didChange", {"textDocument": {"uri": uri, "version": version}, "contentChanges": [{"text": text}]})
        deadline = time.monotonic() + 60
        labels = set()
        while time.monotonic() < deadline:
            result = request("textDocument/completion", {
                "textDocument": {"uri": uri}, "position": position,
                "context": {"triggerKind": 1},
            })
            items = result.get("items", []) if isinstance(result, dict) else result or []
            labels = {option_name(item) for item in items}
            if expected <= labels:
                break
            time.sleep(0.5)
        assert expected <= labels, f"{prefix}: missing {expected - labels}; got {sorted(labels)[:30]}"
        print(f"{prefix}: {', '.join(sorted(expected))}", flush=True)
        if prefix == "NUR addons":
            # nixd caps large lists; editors must request again as the user types.
            assert isinstance(result, dict) and result.get("isIncomplete"), "NUR list should allow prefix refinement"
        if prefix == "development.languages.dotnet.":
            enable = next(item for item in items if option_name(item) == "enable")
            assert "bool" in str(enable.get("detail", "")).lower(), f"Option type missing: {enable}"
            assert ".NET development tools" in str(enable.get("documentation", "")), f"Option documentation missing: {enable}"
    print("nixd option, package, library, and NUR completion checks passed", flush=True)
except Exception:
    log.seek(0)
    print(log.read()[-6000:], flush=True)
    raise
finally:
    server.terminate()
    try:
        server.wait(timeout=5)
    except subprocess.TimeoutExpired:
        server.kill()
    if server.returncode not in (0, -15):
        log.seek(0)
        print(log.read()[-6000:])
    log.close()
