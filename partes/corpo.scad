// ============================================================
// corpo.scad — torso do robô (mesma pegada do chassi)
// Frente: janela para o micro:bit — a placa desliza por trilhos
// internos a partir de uma fenda no topo (que fica escondida sob
// a cabeça). Dois furos para botões de 12 mm. Laterais: ressaltos
// dos ombros para os braços. Interior: 4 colunas para parafusos
// M3 autoroscantes que prendem o torso ao chassi.
// Imprimir na orientação do modelo (abertura para baixo).
// ============================================================

include <../parametros.scad>

wz       = corpo_h - 22;                       // centro da janela (Z)
mbolso_w = mb_w + 2;                           // largura interna do bolso
mbolso_h = mb_h + 4;                           // altura interna do bolso
mb_y     = -corpo_d/2 + parede + folga + mb_prof/2;    // eixo Y da placa
z_fundo  = mb_base_z;                // topo das prateleiras
trilho_h = corpo_h - z_fundo;                  // altura dos trilhos

module corpo() {
    difference() {
        union() {
            // ---------- casco (fundo aberto) ----------
            difference() {
                rbox(corpo_w, corpo_d, corpo_h, 5);
                translate([0, 0, -0.1])
                    rbox(corpo_w - 2*parede, corpo_d - 2*parede,
                         corpo_h - parede + 0.1, 4);
            }

            // ---------- trilhos do bolso do micro:bit ----------
            for (x = [-1, 1])
                translate([x * (mbolso_w/2 + 2), mb_y,
                           z_fundo + trilho_h/2])
                    difference() {
                        cube([4, mb_prof + 2*folga + 0.2, trilho_h], center = true);
                        // canaleta por onde a placa desliza
                        translate([-x * 1.1, 0, 0])
                            cube([2.2, 3.4, trilho_h + 2],
                                 center = true);
                    }

            // ---------- prateleiras laterais (fundo do bolso) ----------
            // apoiam a placa pelas bordas e deixam o centro livre
            for (x = [-1, 1])
                translate([x * 30, mb_y, z_fundo - 1.5])
                    cube([11.5, mb_prof + 2*folga + 0.2, 3], center = true);

            // ---------- painel traseiro do bolso ----------
            // cobre o bolso e os botões, escondendo o interior
            translate([0, mb_y + mb_prof/2 + folga + 1, corpo_h/2])
                cube([mbolso_w + 8, 2, corpo_h], center = true);

            // ---------- ressaltos dos ombros (pinos dos braços) ----------
            for (x = [-1, 1])
                translate([x * (corpo_w/2 + 2), 0, corpo_h - 14])
                    rotate([0, 90, 0])
                        cylinder(d = 14, h = 6, center = true);

            // ---------- pinos de encaixe da cabeça ----------
            for (x = [-1, 1], y = [-1, 1])
                translate([x * 20, y * 16, corpo_h])
                    cylinder(d = 4.8, h = cab_pino_h);

            // ---------- colunas internas de fixação na base ----------
            for (x = [-1, 1], y = [-1, 1])
                translate([x * mont_x, y * mont_y, 0])
                    cylinder(d = 10, h = 6);
        }

        // ---------- janela do micro:bit ----------
        translate([0, -corpo_d/2, wz])
            cube([44, parede + 4, 32], center = true);

        // ---------- fenda de inserção da placa (no topo) ----------
        translate([0, mb_y, corpo_h - parede/2])
            cube([mb_w + 2*folga, mb_prof + 2*folga, parede + 0.4], center = true);

        translate([0, 0, corpo_h - parede/2])
            cube([passagem_w, passagem_d, parede + 0.4], center = true);

        translate([-passagem_w/2, mb_y + mb_prof/2 - folga, parede])
            cube([passagem_w, 3 + 2*folga, mb_base_z - 2*parede]);

        for (x = [-1, 1], y = [-1, 1])
            translate([x * mont_x, y * mont_y, 6])
                cylinder(d = acesso_m3_d, h = corpo_h);

        // ---------- furos dos botões ----------
        for (x = [-1, 1])
            translate([x * botao_sep/2, -corpo_d/2, botao_z])
                rotate([90, 0, 0])
                    cylinder(d = botao_d, h = parede + 4,
                             center = true);

        // ---------- furos dos ombros ----------
        for (x = [-1, 1])
            translate([x * corpo_w/2, 0, corpo_h - 14])
                rotate([0, 90, 0])
                    cylinder(d = braco_furo, h = 12, center = true);

        // ---------- furos M3 nas colunas de fixação ----------
        for (x = [-1, 1], y = [-1, 1])
            translate([x * mont_x, y * mont_y, -0.1])
                cylinder(d = 3.3, h = 6.5);
    }
}

corpo();
