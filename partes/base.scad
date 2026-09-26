// ============================================================
// base.scad — chassi do robô
// Caixa aberta contendo: baia das pilhas 4xAA, buchas dos eixos
// das 4 rodas e colunas de fixação do torso (M3 + porca sextavada).
// Imprimir na orientação do modelo (abertura para cima).
// ============================================================

include <../parametros.scad>

module base() {
    difference() {
        union() {
            // ---------- casco: caixa aberta ----------
            difference() {
                rbox(base_w, base_d, base_h, 5);
                translate([0, 0, parede])
                    rbox(base_w - 2*parede, base_d - 2*parede,
                         base_h, 4);
            }

            // ---------- colunas dos cantos (fixação do torso) ----------
            for (x = [-1, 1], y = [-1, 1])
                translate([x * mont_x, y * mont_y, parede])
                    cylinder(d = 11, h = base_h - parede);

            // ---------- buchas dos eixos (dentro do casco) ----------
            for (x = [-1, 1], y = [-1, 1])
                translate([x * base_w/2, y * roda_y, eixo_z])
                    rotate([0, -x * 90, 0])
                        cylinder(d = 12, h = 4 + parede);

            for (y = [-1, 1])
                translate([0, y * aa_bay_d/6, suporte_z/2])
                    cube([base_w - parede, 3, suporte_z], center = true);

            // ---------- batentes dos cantos da baia das pilhas ----------
            for (x = [-1, 1], y = [-1, 1])
                translate([x * (aa_bay_w/2 + 1.5),
                           y * (aa_bay_d/2 + 1.5), (suporte_z + 5)/2])
                    cube([3, 3, suporte_z + 5], center = true);
        }

        // ---------- furos dos eixos (atravessam parede + bucha) ----------
        for (x = [-1, 1], y = [-1, 1])
            translate([x * (base_w/2 - 4), y * roda_y, eixo_z])
                rotate([0, 90, 0])
                    cylinder(d = eixo_d + 2*folga, h = 14, center = true);

        // ---------- furos piloto M3 (autoroscante) nas colunas ----------
        for (x = [-1, 1], y = [-1, 1])
            translate([x * mont_x, y * mont_y, -0.1])
                cylinder(d = 2.6, h = base_h + 0.2);

        // ---------- rasgo de passagem do cabo das pilhas ----------
        translate([aa_bay_w/2 - 6, base_d/2 - parede - 1, suporte_z])
            cube([10, parede + 2.2, 7]);
    }
}

base();
