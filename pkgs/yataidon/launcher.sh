#!/usr/bin/env bash
set -euo pipefail

STORE="@out@/share/yataidon"
GAMEDIR="${YATAIDON_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/yataidon}"

mkdir -p "$GAMEDIR/Songs"

# Upstream ships template collection folders (Search, Favorites, Recently
# Played, etc). Seed any that are missing; never touch ones that exist,
# since Favorites and Recently Played store user data in them.
if [ -d "$STORE/Songs" ]; then
  for d in "$STORE/Songs"/*; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    [ -e "$GAMEDIR/Songs/$name" ] && continue
    cp -r --no-preserve=mode "$d" "$GAMEDIR/Songs/$name"
  done
fi

# Read-only assets can be symlinked.
for d in shader Skins; do
  [ -L "$GAMEDIR/$d" ] && rm -f "$GAMEDIR/$d"
  [ -e "$GAMEDIR/$d" ] || ln -s "$STORE/$d" "$GAMEDIR/$d"
done

# Seed a writable config once; never clobber the user's.
if [ ! -f "$GAMEDIR/config.toml" ]; then
  install -m 644 "$STORE/config.toml" "$GAMEDIR/config.toml"
fi

mkdir -p "$GAMEDIR/Songs"

cd "$GAMEDIR"
exec ./YataiDON "$@"
