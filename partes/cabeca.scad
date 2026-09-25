// ============================================================
// cabeca.scad — cabeça do robô
// Frente: janela 34x34 para matriz de LED 8x8 (~32 mm) ou
// display OLED pequeno — o módulo desliza por trilhos internos
// a partir de uma fenda no topo. Topo: antena. Laterais:
// "orelhas". Fundo: placa com 4 furos que encaixam nos pinos
// do torso.
// Imprimir na orientação do modelo (de pé).
// ============================================================

include <../parametros.scad>

wz       = 27;                              // centro da janela (Z)
bolso_w  = led_tam + 1;                     // largura interna do bolso
bolso_h  = led_tam + 3;                     // altura interna do bolso
led_y    = -cab_d/2 + parede + led_prof/2;  // eixo Y do display
z_fundo  = wz - bolso_h/2 - 1;              // topo das prateleiras
trilho_h = cab_h - parede - z_fundo;        // altura dos trilhos

module cabeca() {
    difference() {
        union() {
            // ---------- casco (topo fechado, fundo aberto) ----------
            difference() {
                rbox(cab_w, cab_d, cab_h, 5);
                translate([0, 0, -0.1])
                    rbox(cab_w - 2*parede, cab_d - 2*parede,
                         cab_h - parede + 0.1, 4);
            }
            // placa do fundo
            rbox(cab_w, cab_d, parede, 5);

            // ---------- trilhos do bolso do display ----------
            for (x = [-1, 1])
                translate([x * (bolso_w/2 + 2), led_y,
                           z_fundo + trilho_h/2])
                    difference() {
                        cube([4, led_prof, trilho_h], center = true);
                        translate([-x * 1.1, 0, 0])
                            cube([2.2, 2.6, trilho_h + 2],
                                 center = true);
                    }

            // ---------- prateleiras laterais do bolso ----------
            for (x = [-1, 1])
                translate([x * (bolso_w/2 + 1), led_y,
                           z_fundo - 1.5])
                    cube([7, led_prof, 3], center = true);

            // ---------- painel traseiro do bolso ----------
            translate([0, -13, (z_fundo + cab_h)/2])
                cube([bolso_w + 8, 2, cab_h - z_fundo], center = true);

            // ---------- antena ----------
            translate([0, 14, cab_h]) {
                cylinder(d = 3, h = 13);
                translate([0, 0, 13]) sphere(d = 7);
            }

            // ---------- orelhas ----------
            for (x = [-1, 1])
                translate([x * cab_w/2, 0, 30])
                    rotate([0, 90, 0])
                        cylinder(d = 8, h = 5);
        }

        // ---------- janela do display ----------
        translate([0, -cab_d/2, wz])
            cube([34, parede + 4, 34], center = true);

        // ---------- fenda de inserção do display (no topo) ----------
        translate([0, led_y, cab_h - parede/2])
            cube([bolso_w + 2, 6, parede + 0.4], center = true);

        // ---------- furos dos pinos do torso ----------
        for (x = [-1, 1], y = [-1, 1])
            translate([x * 20, y * 16, -0.1])
                cylinder(d = 5.2, h = parede + 0.2);
    }
}

cabeca();
