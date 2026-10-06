#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

url="https://github.com/Yonokid/YataiDON/releases/download/latest/YataiDON-Linux.zip"

date=$(curl -sfL https://api.github.com/repos/Yonokid/YataiDON/releases/tags/latest \
    | python3 -c 'import json,sys; print(next(a["updated_at"][:10] for a in json.load(sys.stdin)["assets"] if a["name"] == "YataiDON-Linux.zip"))')
hash=$(nix hash convert --hash-algo sha256 --to sri "$(nix-prefetch-url "$url")")

cat > pkgs/yataidon/release.json <<JSON
{
    "version": "0-unstable-$date",
    "hash": "$hash"
}
JSON

echo "yataidon 0-unstable-$date $hash"
