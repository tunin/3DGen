// ============================================================
// robo.scad — arquivo principal do projeto
// Use a variável "part" (linha de comando ou customizador) para
// escolher o que renderizar:
//   montagem       — robô completo montado (visualização)
//   base           — chassi
//   suporte_pilhas — berço para 4 pilhas AA
//   roda           — roda (imprimir 4x)
//   eixo           — eixo + trava (imprimir 2x)
//   corpo          — torso
//   cabeca         — cabeça
//   braco          — braço, 2 peças (imprimir 2x)
//   pino           — pino + trava de articulação (imprimir 4x)
//
// Ex.: openscad -o stl/roda.stl -D 'part="roda"' robo.scad
// ============================================================

part = "montagem";

include <parametros.scad>
use <partes/base.scad>
use <partes/suporte_pilhas.scad>
use <partes/roda.scad>
use <partes/eixo.scad>
use <partes/corpo.scad>
use <partes/cabeca.scad>
use <partes/braco.scad>
use <partes/pino.scad>

// altura do fundo do chassi acima do solo (vão livre)
z_base = roda_d/2 - eixo_z;   // = 6 mm
z_corpo = z_base + base_h;    // torso sobre o chassi
z_cabeca = z_corpo + corpo_h; // cabeça sobre o torso

// ---------- braço montado (ombro + cotovelo articulados) ----------
module braco_montado() {
    // segmento superior inclinado para fora e para baixo
    rotate([0, 65, 0])
        braco_sup();
    // antebraço a partir do cotovelo
    translate([brac_a * cos(65), 0, -brac_a * sin(65)])
        rotate([0, 40, 0])
            braco_inf();
}

module montagem() {
    // chassi
    color("#3f7fbf") translate([0, 0, z_base]) base();
    // berço das pilhas
    color("#e0a030") translate([0, 0, z_base + parede])
        suporte_pilhas();
    // eixos + rodas
    for (y = [-1, 1]) {
        color("#c04040")
            translate([-55, y * roda_y, z_base + eixo_z])
                eixo();
        for (x = [-1, 1])
            color("#404040")
                translate([x * 48, y * roda_y, z_base + eixo_z])
                    rotate([0, 90, 0]) roda();
    }
    // torso
    color("#40a060") translate([0, 0, z_corpo]) corpo();
    // cabeça
    color("#e0e0e0") translate([0, 0, z_cabeca]) cabeca();
    // braços nos ombros
    for (x = [-1, 1])
        color("#8060c0")
            translate([x * (corpo_w/2 + 5), 0,
                       z_corpo + corpo_h - 14])
                rotate([0, 0, x > 0 ? 0 : 180])
                    braco_montado();
}

if (part == "montagem")       montagem();
else if (part == "base")           base();
else if (part == "suporte_pilhas") suporte_pilhas();
else if (part == "roda")           roda();
else if (part == "eixo")           { eixo(); translate([10,0,0]) trava_eixo(); }
else if (part == "corpo")          corpo();
else if (part == "cabeca")         cabeca();
else if (part == "braco")          braco();
else if (part == "pino")           { pino(); translate([14,0,0]) trava_pino(); }
else echo("part desconhecida:", part);
