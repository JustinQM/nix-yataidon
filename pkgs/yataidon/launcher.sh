#!/usr/bin/env bash
set -euo pipefail

STORE="@out@/share/yataidon"
GAMEDIR="${YATAIDON_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/yataidon}"

mkdir -p "$GAMEDIR/Songs"

if [ -d "$STORE/Songs" ]; then
  for d in "$STORE/Songs"/*; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    [ -e "$GAMEDIR/Songs/$name" ] && continue
    cp -r --no-preserve=mode "$d" "$GAMEDIR/Songs/$name"
  done
fi

for d in shader Skins; do
  rm -rf "$GAMEDIR/$d"
  ln -s "$STORE/$d" "$GAMEDIR/$d"
done

# pull the most up to date binary from the store
install -m 755 "$STORE/YataiDON" "$GAMEDIR/YataiDON"

# Seed a writable config once; never clobber the user's.
if [ ! -f "$GAMEDIR/config.toml" ]; then
  install -m 644 "$STORE/config.toml" "$GAMEDIR/config.toml"
fi

cd "$GAMEDIR"
exec ./YataiDON "$@"
