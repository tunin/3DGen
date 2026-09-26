// ============================================================
// pino.scad — pino articulado para os ombros e cotovelos
// Imprimir 4x o pino e 4x a trava (ombro e cotovelo de 2 braços).
// Alternativa mais robusta: parafuso M4x20 + porca autotravante.
// ============================================================

include <../parametros.scad>

pino_l = 12;   // comprimento útil (parede + ressalto + braço)

module pino() {
    union() {
        cylinder(d = 8, h = 2);                    // cabeça
        translate([0, 0, 2])
            cylinder(d = braco_furo - 0.5, h = pino_l);  // haste
        translate([0, 0, 2 + pino_l])
            cylinder(d1 = braco_furo - 0.5, d2 = braco_furo - 2.2,
                     h = 3);                        // ponta cônica
    }
}

module trava_pino() {
    // capa de pressão para a ponta do pino
    difference() {
        cylinder(d = 9, h = 4);
        translate([0, 0, -0.1])
            cylinder(d = braco_furo - 0.9, h = 4.2);
    }
}

// layout para impressão
pino();
translate([14, 0, 0]) trava_pino();
