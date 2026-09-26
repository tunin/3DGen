// ============================================================
// eixo.scad — eixo das rodas e trava (imprimir 2 conjuntos)
// O eixo atravessa o chassi; a roda gira livre sobre ele e a
// trava é pressionada na ponta. Alternativa: usar parafuso M4.
// ============================================================

include <../parametros.scad>

module eixo() {
    // haste com cabeça (batente) e ponta chanfrada
    rotate([0, 90, 0]) {
        translate([0, 0, -2])
            cylinder(d = 10, h = 2);                 // cabeça
        cylinder(d = eixo_d - 0.1, h = eixo_l - 4);  // haste
        translate([0, 0, eixo_l - 4])
            cylinder(d1 = eixo_d - 0.1, d2 = eixo_d - 2.4,
                     h = 4);                          // chanfro
    }
}

module trava_eixo() {
    // anel de pressão: furo apertado que segura na ponta do eixo
    difference() {
        cylinder(d = 10, h = 4);
        translate([0, 0, -0.1])
            cylinder(d = eixo_d - 0.1 - aperto_trava, h = 4.2);
    }
}

// layout para impressão: eixo + trava lado a lado
module eixo_impressao() {
    translate([0, 0, 2]) rotate([0, -90, 0]) eixo();
    translate([14, 0, 0]) trava_eixo();
}

eixo_impressao();
