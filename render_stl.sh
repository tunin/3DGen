#!/usr/bin/env bash
# Gera stl/*.stl (equivalente ao alvo `all` do Makefile). Requer openscad.
set -e
cd "$(dirname "$0")"
mkdir -p stl

OPENSCAD="${OPENSCAD:-openscad}"
command -v "$OPENSCAD" >/dev/null 2>&1 || OPENSCAD="/c/Program Files/OpenSCAD/openscad.com"

for p in base suporte_pilhas roda eixo corpo cabeca braco pino montagem; do
  echo "== $p"
  "$OPENSCAD" -o "stl/$p.stl" -D "part=\"$p\"" robo.scad
done
