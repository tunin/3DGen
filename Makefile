# Gera os STLs (e previews) do robô. Requer openscad; xvfb para imagens.
OPENSCAD ?= openscad
PARTS     = base suporte_pilhas roda eixo corpo cabeca braco pino
STLS      = $(PARTS:%=stl/%.stl)

all: $(STLS)

stl/%.stl: robo.scad parametros.scad partes/%.scad
	@mkdir -p stl
	$(OPENSCAD) -o $@ -D 'part="$*"' robo.scad

stl/montagem.stl: robo.scad parametros.scad partes/*.scad
	@mkdir -p stl
	$(OPENSCAD) -o $@ -D 'part="montagem"' robo.scad

img: $(STLS) stl/montagem.stl
	@mkdir -p img
	./render_img.sh

clean:
	rm -rf stl img

.PHONY: all img clean
