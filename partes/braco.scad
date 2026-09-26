// ============================================================
// braco.scad — braço articulado (imprimir 2x, peças iguais)
// Dois segmentos com furos para articulação (parafuso M4 + porca
// ou pino impresso de pino.scad) e garra de 2 dedos na ponta.
// Imprimir deitado, como no modelo.
// ============================================================

include <../parametros.scad>
// brac_a, brac_b e brac_r vêm de parametros.scad

module braco_sup() {
    // segmento ombro→cotovelo
    difference() {
        hull()
            for (p = [0, brac_a])
                translate([p, 0, 0])
                    cylinder(r = brac_r, h = braco_e);
        for (p = [0, brac_a])
            translate([p, 0, -0.1])
                cylinder(d = braco_furo, h = braco_e + 0.2);
    }
}

module braco_inf() {
    // antebraço com garra de 2 dedos
    difference() {
        union() {
            hull()
                for (p = [0, brac_b])
                    translate([p, 0, 0])
                        cylinder(r = brac_r, h = braco_e);
            // palma
            translate([brac_b, 0, 0])
                cube([2 * brac_r, 2 * brac_r, braco_e]);
            // dedos da garra
            for (y = [-1, 1])
                translate([brac_b + 2 * brac_r - 1,
                           y * (brac_r - 1.5), 0])
                    cube([12, 3, braco_e]);
        }
        // furo da articulação (cotovelo)
        translate([0, 0, -0.1])
            cylinder(d = braco_furo, h = braco_e + 0.2);
        // abertura entre os dedos da garra
        translate([brac_b + 2 * brac_r + 9, 0, -0.1])
            cube([8, 8.2, braco_e + 0.2], center = true);
        // boca da garra (entalhe interno)
        translate([brac_b + 2 * brac_r + 1, 0, -0.1])
            cylinder(d = 5, h = braco_e + 0.2);
    }
}

module braco() {
    // layout de impressão: duas peças lado a lado
    braco_sup();
    translate([0, 22, 0]) braco_inf();
}

braco();
