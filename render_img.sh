#!/usr/bin/env bash
# Gera previews PNG de cada peça em img/ (requer openscad + xvfb).
set -e
cd "$(dirname "$0")"
mkdir -p img

render() { # parte camera
  xvfb-run -a openscad -o "img/$1.png" --imgsize=900,700 \
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

xvfb-run -a openscad -o img/montagem.png --imgsize=1400,1000 \
    --camera=0,-15,75,60,0,-30,430 -D 'part="montagem"' robo.scad
xvfb-run -a openscad -o img/montagem_tras.png --imgsize=1400,1000 \
    --camera=0,15,75,60,0,150,430 -D 'part="montagem"' robo.scad
