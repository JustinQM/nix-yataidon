#!/usr/bin/env bash
set -euo pipefail

STORE="@out@/share/yataidon"
GAMEDIR="${YATAIDON_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/yataidon}"

mkdir -p "$GAMEDIR"

# The game derives its working directory from the executable path and
# writes a sqlite database next to it, so the binary must live in a
# writable directory rather than the store.
if ! cmp -s "$STORE/YataiDON" "$GAMEDIR/YataiDON"; then
  rm -f "$GAMEDIR/YataiDON"
  install -m 755 "$STORE/YataiDON" "$GAMEDIR/YataiDON"
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
