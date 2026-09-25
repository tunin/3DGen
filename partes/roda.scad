// ============================================================
// roda.scad — roda do robô (imprimir 4x)
// Sulco no aro para elástico/anel de borracha como "pneu".
// Furo central gira livre sobre o eixo.
// Imprimir deitada (como no modelo), sem suporte.
// ============================================================

include <../parametros.scad>

module roda() {
    difference() {
        union() {
            // aro (anel com bordas arredondadas)
            rotate_extrude()
                hull() {
                    translate([roda_d/2 - 3, 0]) circle(3);
                    translate([roda_d/2 - 8, 0])
                        square([0.2, roda_w - 4], center = true);
                }
            // cubo
            cylinder(d = 12, h = roda_w, center = true);
            // raios
            for (a = [0 : 60 : 300])
                rotate([0, 0, a])
                    translate([8.5, 0, 0])
                        cube([7, 4, roda_w - 4], center = true);
        }
        // furo do eixo (gira livre)
        cylinder(d = eixo_d + 2*folga, h = roda_w + 4, center = true);
        // sulco do "pneu" (elástico/anel de borracha)
        rotate_extrude()
            translate([roda_d/2 - 1.2, 0])
                circle(2.2);
    }
}

roda();
