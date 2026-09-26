#!/usr/bin/env bash
# Gera previews PNG de cada peça em img/ (requer openscad; xvfb só no Linux).
set -e
cd "$(dirname "$0")"
mkdir -p img

OPENSCAD="${OPENSCAD:-openscad}"
command -v "$OPENSCAD" >/dev/null 2>&1 || OPENSCAD="/c/Program Files/OpenSCAD/openscad.com"
if command -v xvfb-run >/dev/null 2>&1; then XVFB="xvfb-run -a"; else XVFB=""; fi

render() { # parte camera
  $XVFB "$OPENSCAD" --render -o "img/$1.png" --imgsize=900,700 --autocenter --viewall \
      --camera="$2" -D "part=\"$1\"" robo.scad
}

render base           "0,-20,10,60,0,-35,320"
render suporte_pilhas "0,0,5,60,0,-35,200"
render roda           "0,0,0,55,0,-30,160"
render eixo           "50,0,2,70,0,-90,300"
render corpo          "0,-15,30,60,0,-30,380"
render cabeca         "0,-15,25,60,0,-30,280"
render braco          "25,15,3,60,0,-40,220"
render pino           "8,0,3,60,0,-30,140"

$XVFB "$OPENSCAD" --render -o img/montagem.png --imgsize=1400,1000 --autocenter --viewall \
    --camera=0,-15,75,60,0,-30,430 -D 'part="montagem"' robo.scad
$XVFB "$OPENSCAD" --render -o img/montagem_tras.png --imgsize=1400,1000 --autocenter --viewall \
    --camera=0,15,75,60,0,150,430 -D 'part="montagem"' robo.scad
